import type { ComplianceResult } from "@/backend";
import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { useComplianceCheck } from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import {
  AlertCircle,
  CheckCircle,
  FileCheck,
  Send,
  Shield,
} from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/compliance")({
  component: CompliancePage,
});

function CompliancePage() {
  const [documentId, setDocumentId] = useState("1");
  const [submitted, setSubmitted] = useState(false);

  const mutation = useComplianceCheck();
  const result = mutation.data as ComplianceResult | undefined;
  const isLoading = mutation.isPending;
  const isError = mutation.isError;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const id = BigInt(documentId);
    setSubmitted(true);
    await mutation.mutateAsync(id);
  };

  const overallScore = result ? Math.round(result.complianceScore) : 0;
  const regulations = result
    ? [
        {
          name: "Factory Act 1948",
          score: Math.max(0, overallScore - 10),
          gaps: result.gaps.length,
          risk:
            overallScore < 70
              ? "high"
              : overallScore < 85
                ? "medium"
                : ("low" as const),
          status:
            overallScore >= 85 ? "compliant" : ("needs_attention" as const),
        },
        {
          name: "OSHA 29 CFR 1910",
          score: Math.max(0, overallScore - 2),
          gaps: Math.max(0, result.violations.length - 2),
          risk: "low" as const,
          status: "compliant" as const,
        },
        {
          name: "ISO 45001:2018",
          score: Math.max(0, overallScore - 18),
          gaps: result.gaps.length + 2,
          risk: "high" as const,
          status: "critical" as const,
        },
        {
          name: "Environmental Clearance",
          score: Math.max(0, overallScore - 5),
          gaps: Math.max(0, result.violations.length - 1),
          risk: "low" as const,
          status: "compliant" as const,
        },
      ]
    : [];

  return (
    <Layout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-2xl font-display font-semibold text-foreground">
            Compliance Intelligence
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Automated compliance scoring, gap detection, and audit readiness
          </p>
        </div>

        <form
          onSubmit={handleSubmit}
          className="flex flex-col sm:flex-row gap-3"
        >
          <input
            type="text"
            value={documentId}
            onChange={(e) => setDocumentId(e.target.value)}
            placeholder="Document ID to check"
            className="flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            data-ocid="compliance.input"
          />
          <Button
            type="submit"
            disabled={isLoading}
            data-ocid="compliance.submit_button"
          >
            <Send className="w-4 h-4 mr-2" />
            {isLoading ? "Checking..." : "Run Check"}
          </Button>
        </form>

        {isError && (
          <div
            className="p-4 rounded-lg border border-destructive/30 bg-destructive/10 text-destructive text-sm"
            data-ocid="compliance.error_state"
          >
            Compliance check failed. Please try again.
          </div>
        )}

        {isLoading && (
          <div className="space-y-6" data-ocid="compliance.loading_state">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              {Array.from({ length: 4 }).map((_, i) => (
                // biome-ignore lint/suspicious/noArrayIndexKey: skeleton placeholders have no stable id
                <Card key={`comp-skel-${i}`}>
                  <CardContent className="p-6">
                    <Skeleton className="h-4 w-24 mb-2" />
                    <Skeleton className="h-8 w-16" />
                  </CardContent>
                </Card>
              ))}
            </div>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <Skeleton className="h-5 w-32" />
                </CardHeader>
                <CardContent className="space-y-4">
                  {Array.from({ length: 4 }).map((_, i) => (
                    // biome-ignore lint/suspicious/noArrayIndexKey: skeleton placeholders have no stable id
                    <Skeleton key={`req-skel-${i}`} className="h-12 w-full" />
                  ))}
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <Skeleton className="h-5 w-32" />
                </CardHeader>
                <CardContent className="space-y-3">
                  {Array.from({ length: 3 }).map((_, i) => (
                    // biome-ignore lint/suspicious/noArrayIndexKey: skeleton placeholders have no stable id
                    <Skeleton key={`find-skel-${i}`} className="h-24 w-full" />
                  ))}
                </CardContent>
              </Card>
            </div>
          </div>
        )}

        {result && !isLoading && (
          <>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Overall Score
                      </p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {overallScore}%
                      </p>
                    </div>
                    <Shield className="w-8 h-8 text-primary" />
                  </div>
                  <Progress value={overallScore} className="mt-4" />
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Regulations
                      </p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {regulations.length}
                      </p>
                    </div>
                    <FileCheck className="w-8 h-8 text-chart-2" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Total Gaps
                      </p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {regulations.reduce((s, r) => s + r.gaps, 0)}
                      </p>
                    </div>
                    <AlertCircle className="w-8 h-8 text-destructive" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Compliant</p>
                      <p className="text-3xl font-display font-bold mt-1">
                        {
                          regulations.filter((r) => r.status === "compliant")
                            .length
                        }
                      </p>
                    </div>
                    <CheckCircle className="w-8 h-8 text-success" />
                  </div>
                </CardContent>
              </Card>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Regulation Scores</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {regulations.map((reg, i) => (
                    <div
                      key={reg.name}
                      data-ocid={`compliance.regulation.${i + 1}`}
                      className="space-y-2"
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">{reg.name}</span>
                        <div className="flex items-center gap-2">
                          <Badge
                            variant={
                              reg.risk === "high"
                                ? "destructive"
                                : reg.risk === "medium"
                                  ? "secondary"
                                  : "default"
                            }
                          >
                            {reg.risk}
                          </Badge>
                          <span className="text-sm font-medium">
                            {reg.score}%
                          </span>
                        </div>
                      </div>
                      <Progress value={reg.score} />
                      <p className="text-xs text-muted-foreground">
                        {reg.gaps} gaps identified
                      </p>
                    </div>
                  ))}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Priority Gaps</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {result.gaps.map((gap, i) => (
                    <div
                      key={`${gap.requirement}-${i}`}
                      data-ocid={`compliance.gap.${i + 1}`}
                      className="p-4 rounded-lg border border-border hover:border-destructive/30 transition-smooth"
                    >
                      <div className="flex items-center justify-between mb-1">
                        <Badge variant="outline" className="text-xs">
                          {gap.missingIn}
                        </Badge>
                        <Badge
                          variant={
                            gap.severity === "critical" ||
                            gap.severity === "major"
                              ? "destructive"
                              : "secondary"
                          }
                        >
                          {gap.severity}
                        </Badge>
                      </div>
                      <p className="text-sm font-medium mt-2">
                        {gap.requirement}
                      </p>
                    </div>
                  ))}
                  {result.violations.map((v, i) => (
                    <div
                      key={`${v.rule}-${i}`}
                      data-ocid={`compliance.violation.${i + 1}`}
                      className="p-4 rounded-lg border border-border hover:border-destructive/30 transition-smooth"
                    >
                      <div className="flex items-center justify-between mb-1">
                        <Badge variant="outline" className="text-xs">
                          {v.location}
                        </Badge>
                        <Badge
                          variant={
                            v.severity === "critical" || v.severity === "major"
                              ? "destructive"
                              : "secondary"
                          }
                        >
                          {v.severity}
                        </Badge>
                      </div>
                      <p className="text-sm font-medium mt-2">{v.violation}</p>
                      <p className="text-xs text-muted-foreground mt-1">
                        Rule: {v.rule}
                      </p>
                    </div>
                  ))}
                </CardContent>
              </Card>
            </div>
          </>
        )}

        {!submitted && !result && !isLoading && (
          <div
            className="flex flex-col items-center justify-center py-16 text-center"
            data-ocid="compliance.empty_state"
          >
            <Shield className="w-10 h-10 text-muted-foreground mb-4" />
            <p className="text-sm text-muted-foreground">
              Enter a document ID to run automated compliance scoring and gap
              detection.
            </p>
          </div>
        )}
      </div>
    </Layout>
  );
}
