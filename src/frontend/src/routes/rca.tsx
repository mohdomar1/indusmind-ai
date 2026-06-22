import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useRootCauseAnalysis } from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import {
  AlertTriangle,
  FileText,
  Lightbulb,
  Send,
  TrendingUp,
} from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/rca")({
  component: RCAPage,
});

function RCAPage() {
  const [query, setQuery] = useState("Why does Boiler B-12 repeatedly fail?");
  const [equipmentId, setEquipmentId] = useState("B-12");
  const [submitted, setSubmitted] = useState(false);

  const mutation = useRootCauseAnalysis();
  const result = mutation.data;
  const isLoading = mutation.isPending;
  const isError = mutation.isError;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;
    setSubmitted(true);
    await mutation.mutateAsync({
      userQuery: query,
      equipmentId: equipmentId || null,
    });
  };

  return (
    <Layout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-2xl font-display font-semibold text-foreground">
            Root Cause Analysis
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            AI-powered failure pattern detection and cause identification
          </p>
        </div>

        <form
          onSubmit={handleSubmit}
          className="flex flex-col sm:flex-row gap-3"
        >
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Describe the failure or equipment issue..."
            className="flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            data-ocid="rca.input"
          />
          <input
            type="text"
            value={equipmentId}
            onChange={(e) => setEquipmentId(e.target.value)}
            placeholder="Equipment ID (optional)"
            className="w-full sm:w-40 rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            data-ocid="rca.equipment_input"
          />
          <Button
            type="submit"
            disabled={isLoading}
            data-ocid="rca.submit_button"
          >
            <Send className="w-4 h-4 mr-2" />
            {isLoading ? "Analyzing..." : "Run Analysis"}
          </Button>
        </form>

        {isError && (
          <div
            className="p-4 rounded-lg border border-destructive/30 bg-destructive/10 text-destructive text-sm"
            data-ocid="rca.error_state"
          >
            Analysis failed. Please try again.
          </div>
        )}

        {isLoading && (
          <div
            className="grid grid-cols-1 lg:grid-cols-3 gap-6"
            data-ocid="rca.loading_state"
          >
            <Card className="lg:col-span-2">
              <CardHeader>
                <Skeleton className="h-5 w-48" />
              </CardHeader>
              <CardContent className="space-y-4">
                <Skeleton className="h-16 w-full" />
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-24 w-full" />
              </CardContent>
            </Card>
            <div className="space-y-4">
              <Card>
                <CardHeader>
                  <Skeleton className="h-4 w-24" />
                </CardHeader>
                <CardContent className="space-y-3">
                  <Skeleton className="h-12 w-full" />
                  <Skeleton className="h-12 w-full" />
                  <Skeleton className="h-12 w-full" />
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <Skeleton className="h-4 w-32" />
                </CardHeader>
                <CardContent className="space-y-3">
                  <Skeleton className="h-10 w-full" />
                  <Skeleton className="h-10 w-full" />
                  <Skeleton className="h-10 w-full" />
                </CardContent>
              </Card>
            </div>
          </div>
        )}

        {result && !isLoading && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Card className="lg:col-span-2">
              <CardHeader>
                <div className="flex items-center gap-2">
                  <AlertTriangle className="w-5 h-5 text-destructive" />
                  <CardTitle>Analysis: {result.userQuery}</CardTitle>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="p-4 rounded-lg bg-muted/50 border border-border">
                  <p className="text-sm text-muted-foreground mb-2">Query</p>
                  <p className="text-sm font-medium">{result.userQuery}</p>
                  {result.equipmentId && (
                    <p className="text-xs text-muted-foreground mt-1">
                      Equipment: {result.equipmentId}
                    </p>
                  )}
                </div>

                <div className="space-y-3">
                  <h3 className="text-sm font-semibold text-foreground">
                    Most Likely Causes
                  </h3>
                  {result.likelyCauses.map((cause, i) => (
                    <div
                      key={cause.cause}
                      data-ocid={`rca.cause.${i + 1}`}
                      className="p-4 rounded-lg border border-border hover:border-primary/30 transition-smooth"
                    >
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm font-medium">
                          {cause.cause}
                        </span>
                        <Badge
                          variant={
                            cause.probability >= 0.7
                              ? "destructive"
                              : cause.probability >= 0.4
                                ? "secondary"
                                : "default"
                          }
                        >
                          {Math.round(cause.probability * 100)}%
                        </Badge>
                      </div>
                      {cause.supportingEvidence.length > 0 && (
                        <p className="text-xs text-muted-foreground mb-2">
                          {cause.supportingEvidence.join("; ")}
                        </p>
                      )}
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <TrendingUp className="w-3 h-3" />
                        {Math.round(cause.probability * 100)}% confidence
                      </div>
                    </div>
                  ))}
                </div>

                {result.evidence.length > 0 && (
                  <div className="space-y-3">
                    <h3 className="text-sm font-semibold text-foreground">
                      Evidence
                    </h3>
                    {result.evidence.map((ev, i) => (
                      <div
                        key={`ev-${ev.documentName}-${i}`}
                        data-ocid={`rca.evidence.${i + 1}`}
                        className="p-3 rounded-md bg-muted/30 border border-border"
                      >
                        <div className="flex items-center justify-between mb-1">
                          <span className="text-xs font-medium">
                            {ev.documentName}
                          </span>
                          <span className="text-xs text-muted-foreground">
                            {Math.round(ev.relevanceScore * 100)}% relevance
                          </span>
                        </div>
                        <p className="text-xs text-muted-foreground">
                          {ev.excerpt}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>

            <div className="space-y-4">
              {result.similarFailures.length > 0 && (
                <Card>
                  <CardHeader>
                    <CardTitle className="text-sm">Similar History</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {result.similarFailures.map((h, i) => (
                      <div
                        key={`hist-${h.equipmentId}-${i}`}
                        data-ocid={`rca.history.${i + 1}`}
                        className="flex items-start gap-3 p-3 rounded-md bg-muted/30"
                      >
                        <FileText className="w-4 h-4 text-muted-foreground mt-0.5" />
                        <div>
                          <p className="text-sm font-medium">{h.description}</p>
                          <p className="text-xs text-muted-foreground">
                            {h.date} · {h.equipmentId} ·{" "}
                            {Math.round(h.similarityScore * 100)}% match
                          </p>
                        </div>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              )}

              {result.recommendedActions.length > 0 && (
                <Card>
                  <CardHeader>
                    <CardTitle className="text-sm">
                      Recommended Actions
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {result.recommendedActions.map((action, i) => (
                      // biome-ignore lint/suspicious/noArrayIndexKey: string array items have no stable id
                      <div key={`act-${i}`} className="flex items-start gap-2">
                        <Lightbulb className="w-4 h-4 text-primary mt-0.5" />
                        <p className="text-sm">{action}</p>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              )}
            </div>
          </div>
        )}

        {!submitted && !result && !isLoading && (
          <div
            className="flex flex-col items-center justify-center py-16 text-center"
            data-ocid="rca.empty_state"
          >
            <AlertTriangle className="w-10 h-10 text-muted-foreground mb-4" />
            <p className="text-sm text-muted-foreground">
              Enter a failure query and equipment ID to run AI-powered root
              cause analysis.
            </p>
          </div>
        )}
      </div>
    </Layout>
  );
}
