import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useDashboardStats, useRecentActivity } from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import {
  Activity,
  AlertTriangle,
  BookOpen,
  FileText,
  MessageSquare,
  Network,
  Shield,
  TrendingUp,
} from "lucide-react";

export const Route = createFileRoute("/")({
  component: DashboardHome,
});

function DashboardHome() {
  const { data: stats, isLoading: statsLoading } = useDashboardStats();
  const { data: activity, isLoading: activityLoading } = useRecentActivity(5n);

  const kpiCards = stats
    ? [
        {
          title: "Documents Ingested",
          value: String(stats.totalDocuments),
          change: "+12%",
          icon: FileText,
          color: "text-primary",
          bg: "bg-primary/10",
        },
        {
          title: "Copilot Queries",
          value: String(stats.totalChatThreads),
          change: "+28%",
          icon: MessageSquare,
          color: "text-chart-2",
          bg: "bg-chart-2/10",
        },
        {
          title: "Graph Nodes",
          value: String(stats.totalEntities),
          change: "+5%",
          icon: Network,
          color: "text-chart-1",
          bg: "bg-chart-1/10",
        },
        {
          title: "RCA Analyses",
          value: String(stats.totalIncidents),
          change: "+8%",
          icon: AlertTriangle,
          color: "text-chart-4",
          bg: "bg-chart-4/10",
        },
        {
          title: "Compliance Score",
          value: `${stats.totalComplianceChecks > 0n ? Math.round(Number(stats.totalComplianceChecks) * 8) : 0}%`,
          change: "+3.2%",
          icon: Shield,
          color: "text-success",
          bg: "bg-success/10",
        },
        {
          title: "Patterns Detected",
          value: String(stats.totalRelationships),
          change: "+15%",
          icon: BookOpen,
          color: "text-chart-3",
          bg: "bg-chart-3/10",
        },
      ]
    : [];

  const formatTimeAgo = (timestamp: bigint) => {
    const now = BigInt(Math.floor(Date.now() / 1000));
    const diff = now - timestamp;
    if (diff < 60n) return "Just now";
    if (diff < 3600n) return `${String(diff / 60n)}m ago`;
    if (diff < 86400n) return `${String(diff / 3600n)}h ago`;
    return `${String(diff / 86400n)}d ago`;
  };

  return (
    <Layout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-2xl font-display font-semibold text-foreground">
            INDUSMIND AI Dashboard
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Industrial Knowledge Intelligence Platform — Real-time overview
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {statsLoading
            ? Array.from({ length: 6 }).map(() => (
                <Card
                  key="kpi-skeleton"
                  className="hover:border-primary/30 transition-smooth"
                >
                  <CardContent className="p-5">
                    <div className="space-y-3">
                      <Skeleton className="h-4 w-24" />
                      <Skeleton className="h-8 w-16" />
                      <Skeleton className="h-5 w-20" />
                    </div>
                  </CardContent>
                </Card>
              ))
            : kpiCards.map((kpi, i) => (
                <Card
                  key={kpi.title}
                  data-ocid={`dashboard.kpi.${i + 1}`}
                  className="hover:border-primary/30 transition-smooth"
                >
                  <CardContent className="p-5">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm text-muted-foreground">
                          {kpi.title}
                        </p>
                        <p className="text-2xl font-display font-bold mt-1">
                          {kpi.value}
                        </p>
                        <Badge variant="secondary" className="mt-2 text-xs">
                          <TrendingUp className="w-3 h-3 mr-1" />
                          {kpi.change} this month
                        </Badge>
                      </div>
                      <div
                        className={`w-10 h-10 rounded-lg ${kpi.bg} flex items-center justify-center`}
                      >
                        <kpi.icon className={`w-5 h-5 ${kpi.color}`} />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <Card className="lg:col-span-2">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Activity className="w-5 h-5 text-primary" />
                <CardTitle className="text-base">Recent Activity</CardTitle>
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              {activityLoading ? (
                Array.from({ length: 5 }).map(() => (
                  <div
                    key="act-skeleton"
                    className="flex items-center justify-between p-3 rounded-md bg-muted/30"
                  >
                    <div className="space-y-2">
                      <Skeleton className="h-4 w-32" />
                      <Skeleton className="h-3 w-48" />
                    </div>
                    <Skeleton className="h-3 w-12" />
                  </div>
                ))
              ) : activity && activity.length > 0 ? (
                activity.map((item, i) => (
                  <div
                    key={item.id.toString()}
                    data-ocid={`dashboard.activity.${i + 1}`}
                    className="flex items-center justify-between p-3 rounded-md bg-muted/30 hover:bg-muted/50 transition-fast"
                  >
                    <div>
                      <p className="text-sm font-medium">{item.activityType}</p>
                      <p className="text-xs text-muted-foreground">
                        {item.description}
                      </p>
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {formatTimeAgo(item.timestamp)}
                    </span>
                  </div>
                ))
              ) : (
                <div className="p-8 text-center text-muted-foreground text-sm">
                  No recent activity
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">System Health</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-muted-foreground">
                    Document Pipeline
                  </span>
                  <span className="text-sm font-medium text-success">
                    Healthy
                  </span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div className="h-full w-[94%] bg-success rounded-full" />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-muted-foreground">
                    RAG Index
                  </span>
                  <span className="text-sm font-medium text-success">
                    Healthy
                  </span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div className="h-full w-[97%] bg-success rounded-full" />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-muted-foreground">
                    Knowledge Graph
                  </span>
                  <span className="text-sm font-medium text-success">
                    Healthy
                  </span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div className="h-full w-[91%] bg-success rounded-full" />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-muted-foreground">
                    Agent Coordinator
                  </span>
                  <span className="text-sm font-medium text-warning">
                    Degraded
                  </span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div className="h-full w-[76%] bg-warning rounded-full" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </Layout>
  );
}
