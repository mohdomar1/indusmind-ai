import { Layout } from "@/components/Layout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { Switch } from "@/components/ui/switch";
import { createFileRoute } from "@tanstack/react-router";
import { Bell, Database, Settings, Shield, Users } from "lucide-react";

export const Route = createFileRoute("/settings")({
  component: SettingsPage,
});

function SettingsPage() {
  return (
    <Layout>
      <div className="p-6 space-y-6 max-w-3xl">
        <div>
          <h1 className="text-2xl font-display font-semibold text-foreground">
            Settings
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Configure platform preferences and integrations
          </p>
        </div>

        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Bell className="w-5 h-5 text-primary" />
              <CardTitle className="text-base">Notifications</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Compliance Alerts</Label>
                <p className="text-xs text-muted-foreground">
                  Get notified when compliance scores drop
                </p>
              </div>
              <Switch data-ocid="settings.compliance_alerts" defaultChecked />
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">RCA Reports</Label>
                <p className="text-xs text-muted-foreground">
                  Email weekly root cause analysis summaries
                </p>
              </div>
              <Switch data-ocid="settings.rca_reports" defaultChecked />
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Lessons Learned</Label>
                <p className="text-xs text-muted-foreground">
                  Alert when new patterns are detected
                </p>
              </div>
              <Switch data-ocid="settings.lessons_alerts" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Database className="w-5 h-5 text-primary" />
              <CardTitle className="text-base">Data & Integrations</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Auto-ingest Emails</Label>
                <p className="text-xs text-muted-foreground">
                  Process email archives for knowledge extraction
                </p>
              </div>
              <Switch data-ocid="settings.auto_ingest" />
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Knowledge Graph Sync</Label>
                <p className="text-xs text-muted-foreground">
                  Real-time updates to Neo4j graph
                </p>
              </div>
              <Switch data-ocid="settings.graph_sync" defaultChecked />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Shield className="w-5 h-5 text-primary" />
              <CardTitle className="text-base">Security</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Require 2FA</Label>
                <p className="text-xs text-muted-foreground">
                  Enforce two-factor authentication for all users
                </p>
              </div>
              <Switch data-ocid="settings.require_2fa" />
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <div>
                <Label className="text-sm">Audit Logging</Label>
                <p className="text-xs text-muted-foreground">
                  Log all document access and queries
                </p>
              </div>
              <Switch data-ocid="settings.audit_logging" defaultChecked />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-primary" />
              <CardTitle className="text-base">Team</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <Button
              data-ocid="settings.invite_team"
              variant="outline"
              className="gap-2"
            >
              <Users className="w-4 h-4" />
              Invite Team Members
            </Button>
          </CardContent>
        </Card>
      </div>
    </Layout>
  );
}
