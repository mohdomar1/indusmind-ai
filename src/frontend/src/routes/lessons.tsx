import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Skeleton } from "@/components/ui/skeleton";
import { useLessonsLearnedAnalysis } from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import {
  AlertTriangle,
  BookOpen,
  Clock,
  Loader2,
  Search,
  TrendingUp,
} from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/lessons")({
  component: LessonsPage,
});

function LessonsPage() {
  const [incidentId, setIncidentId] = useState("");
  const analysis = useLessonsLearnedAnalysis();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    analysis.mutate();
  };

  const result = analysis.data;
  const isLoading = analysis.isPending;
  const isError = analysis.isError;

  const insights = result
    ? result.patterns.map((p) => ({
        pattern: p.patternName,
        frequency: `${Number(p.occurrenceCount)} occurrence${Number(p.occurrenceCount) !== 1 ? "s" : ""}`,
        period: "From analysis",
        risk: "high",
        condition: p.description,
        recommendation:
          result.preventiveActions.find((a) =>
            p.affectedEquipment.some((eq) => a.action.includes(eq)),
          )?.action ??
          result.preventiveActions[0]?.action ??
          "Review and monitor",
        documents: p.affectedEquipment.map((eq) => `${eq}_Maint_Record.pdf`),
      }))
    : [];

  const highRiskCount = result
    ? result.highRiskConditions.filter(
        (c) => c.riskLevel === "high" || c.riskLevel === "critical",
      ).length
    : 0;

  return (
    <Layout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-2xl font-display font-semibold text-foreground">
            Lessons Learned Intelligence
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Pattern detection from incidents, near misses, and audit findings
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex items-end gap-3">
          <div className="flex-1 space-y-2">
            <Label
              htmlFor="incidentId"
              className="text-sm text-muted-foreground"
            >
              Incident ID (optional)
            </Label>
            <Input
              id="incidentId"
              data-ocid="lessons.incident_input"
              placeholder="e.g. INC-2024-001"
              value={incidentId}
              onChange={(e) => setIncidentId(e.target.value)}
            />
          </div>
          <Button
            type="submit"
            data-ocid="lessons.analyze_button"
            disabled={isLoading}
          >
            {isLoading ? (
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
            ) : (
              <Search className="w-4 h-4 mr-2" />
            )}
            Run Analysis
          </Button>
        </form>

        {isError && (
          <div
            data-ocid="lessons.error_state"
            className="p-4 rounded-lg border border-destructive/30 bg-destructive/10 text-destructive text-sm"
          >
            Analysis failed. Please try again.
          </div>
        )}

        {isLoading && (
          <div data-ocid="lessons.loading_state" className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Card>
                <CardContent className="p-6">
                  <Skeleton className="h-8 w-16" />
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <Skeleton className="h-8 w-16" />
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <Skeleton className="h-8 w-16" />
                </CardContent>
              </Card>
            </div>
            <Card>
              <CardContent className="p-6 space-y-3">
                <Skeleton className="h-5 w-1/3" />
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-2/3" />
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 space-y-3">
                <Skeleton className="h-5 w-1/3" />
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-2/3" />
              </CardContent>
            </Card>
          </div>
        )}

        {!isLoading && !result && !isError && (
          <div
            data-ocid="lessons.empty_state"
            className="flex flex-col items-center justify-center py-16 text-muted-foreground"
          >
            <BookOpen className="w-12 h-12 mb-4 opacity-40" />
            <p className="text-sm">
              Run an analysis to discover patterns and preventive actions.
            </p>
          </div>
        )}

        {result && (
          <>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Patterns Detected
                      </p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {insights.length}
                      </p>
                    </div>
                    <BookOpen className="w-8 h-8 text-primary" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">High Risk</p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {highRiskCount}
                      </p>
                    </div>
                    <AlertTriangle className="w-8 h-8 text-destructive" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Preventive Actions
                      </p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {result.preventiveActions.length}
                      </p>
                    </div>
                    <Clock className="w-8 h-8 text-chart-2" />
                  </div>
                </CardContent>
              </Card>
            </div>

            <div className="space-y-4">
              {insights.map((insight, i) => (
                <Card
                  key={insight.pattern}
                  data-ocid={`lessons.insight.${i + 1}`}
                  className="hover:border-primary/30 transition-smooth"
                >
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <TrendingUp className="w-5 h-5 text-primary" />
                        <CardTitle className="text-base">
                          {insight.pattern}
                        </CardTitle>
                      </div>
                      <Badge
                        variant={
                          insight.risk === "high" ? "destructive" : "secondary"
                        }
                      >
                        {insight.risk} risk
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div className="p-3 rounded-md bg-muted/30">
                        <p className="text-xs text-muted-foreground mb-1">
                          Frequency
                        </p>
                        <p className="text-sm font-medium">
                          {insight.frequency}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          {insight.period}
                        </p>
                      </div>
                      <div className="p-3 rounded-md bg-muted/30 md:col-span-2">
                        <p className="text-xs text-muted-foreground mb-1">
                          Detected Condition
                        </p>
                        <p className="text-sm">{insight.condition}</p>
                      </div>
                    </div>

                    <div className="p-4 rounded-lg border border-primary/20 bg-primary/5">
                      <p className="text-xs text-primary font-medium mb-1">
                        Recommended Action
                      </p>
                      <p className="text-sm">{insight.recommendation}</p>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      {insight.documents.map((doc) => (
                        <Badge key={doc} variant="outline" className="text-xs">
                          {doc}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </>
        )}
      </div>
    </Layout>
  );
}
