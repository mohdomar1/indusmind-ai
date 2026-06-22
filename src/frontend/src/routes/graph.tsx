import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { createFileRoute } from "@tanstack/react-router";
import {
  Background,
  Controls,
  type Edge,
  type Node,
  ReactFlow,
  ReactFlowProvider,
  useEdgesState,
  useNodesState,
  useReactFlow,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";
import type { GraphEdge, GraphNode } from "@/backend";
import { useGraphData } from "@/hooks/useQueries";
import {
  AlertTriangle,
  BookOpen,
  Cog,
  FileText,
  Network,
  RotateCcw,
  Search,
  Shield,
  User,
  X,
  ZoomIn,
  ZoomOut,
} from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";

export const Route = createFileRoute("/graph")({
  component: GraphPageWrapper,
});

const entityTypeColors: Record<string, string> = {
  equipment: "#3b82f6",
  asset: "#3b82f6",
  failure: "#ef4444",
  document: "#10b981",
  person: "#a855f7",
  event: "#f59e0b",
  procedure: "#06b6d4",
  regulation: "#6366f1",
  location: "#8b5cf6",
  other: "#6b7280",
};

const entityTypeIcons: Record<string, React.ElementType> = {
  equipment: Cog,
  asset: Cog,
  failure: AlertTriangle,
  document: FileText,
  person: User,
  event: Network,
  procedure: BookOpen,
  regulation: Shield,
  location: Network,
  other: Network,
};

function CustomNode({ data }: { data: Record<string, unknown> }) {
  const type = (data.type as string) || "other";
  const color = entityTypeColors[type] || entityTypeColors.other;
  const Icon = entityTypeIcons[type] || Network;
  const isSelected = !!data.selected;

  return (
    <div
      className={`px-3 py-2 rounded-lg border shadow-sm transition-all duration-200 cursor-pointer min-w-[140px] ${
        isSelected
          ? "ring-2 ring-primary border-primary"
          : "border-border hover:border-primary/50"
      }`}
      style={{ background: "oklch(var(--card))" }}
    >
      <div className="flex items-center gap-2">
        <div
          className="w-6 h-6 rounded-md flex items-center justify-center shrink-0"
          style={{ backgroundColor: `${color}20`, color }}
        >
          <Icon className="w-3.5 h-3.5" />
        </div>
        <span className="text-xs font-medium text-foreground truncate">
          {data.label as string}
        </span>
      </div>
      <div className="mt-1.5 flex items-center gap-1">
        <span
          className="text-[10px] px-1.5 py-0.5 rounded-full font-medium"
          style={{ backgroundColor: `${color}15`, color }}
        >
          {type}
        </span>
      </div>
    </div>
  );
}

const nodeTypes = { custom: CustomNode };

function GraphPage() {
  const { data: graphData, isLoading } = useGraphData(null, 2n);
  const [nodes, setNodes, onNodesChange] = useNodesState<Node>([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState<Edge>([]);
  const [selectedNode, setSelectedNode] = useState<Node | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const { fitView, zoomIn, zoomOut } = useReactFlow();

  // Map backend graph data to React Flow nodes/edges
  useEffect(() => {
    if (!graphData) return;

    const rfNodes: Node[] = graphData.nodes.map((n: GraphNode, i: number) => {
      const angle = (i / Math.max(graphData.nodes.length, 1)) * 2 * Math.PI;
      const radius = 250;
      return {
        id: String(n.id),
        type: "custom",
        position: {
          x: 400 + Math.cos(angle) * radius + (Math.random() - 0.5) * 80,
          y: 250 + Math.sin(angle) * radius + (Math.random() - 0.5) * 80,
        },
        data: {
          label: n.nodeLabel,
          type: n.entityType,
          properties: n.properties,
          selected: selectedNode?.id === String(n.id),
        },
      };
    });

    const rfEdges: Edge[] = graphData.edges.map((e: GraphEdge) => ({
      id: String(e.id),
      source: String(e.source),
      target: String(e.target),
      label: e.edgeLabel,
      type: "smoothstep",
      animated: e.confidence > 0.7,
      style: {
        stroke:
          e.confidence > 0.8 ? "oklch(var(--primary))" : "oklch(var(--border))",
        strokeWidth: e.confidence > 0.8 ? 2 : 1.5,
      },
      labelStyle: {
        fill: "oklch(var(--muted-foreground))",
        fontSize: 10,
      },
      markerEnd: {
        type: "arrowclosed" as const,
        width: 12,
        height: 12,
        color:
          e.confidence > 0.8 ? "oklch(var(--primary))" : "oklch(var(--border))",
      },
    }));

    setNodes(rfNodes);
    setEdges(rfEdges);
  }, [graphData, setNodes, setEdges, selectedNode]);

  // Update selected state on nodes
  useEffect(() => {
    setNodes((nds) =>
      nds.map((n) => ({
        ...n,
        data: { ...n.data, selected: selectedNode?.id === n.id },
      })),
    );
  }, [selectedNode, setNodes]);

  const onNodeClick = useCallback((_: React.MouseEvent, node: Node) => {
    setSelectedNode(node);
  }, []);

  const onPaneClick = useCallback(() => {
    setSelectedNode(null);
  }, []);

  const filteredNodes = useMemo(() => {
    if (!searchQuery.trim()) return nodes;
    const q = searchQuery.toLowerCase();
    return nodes.filter(
      (n) =>
        String(n.data.label).toLowerCase().includes(q) ||
        String(n.data.type).toLowerCase().includes(q),
    );
  }, [nodes, searchQuery]);

  const filteredEdges = useMemo(() => {
    if (!searchQuery.trim()) return edges;
    const nodeIds = new Set(filteredNodes.map((n) => n.id));
    return edges.filter((e) => nodeIds.has(e.source) && nodeIds.has(e.target));
  }, [edges, filteredNodes, searchQuery]);

  const handleFitView = useCallback(() => {
    fitView({ padding: 0.2, duration: 300 });
  }, [fitView]);

  const stats = useMemo(() => {
    if (!graphData) return null;
    const typeCounts: Record<string, number> = {};
    for (const n of graphData.nodes) {
      typeCounts[n.entityType] = (typeCounts[n.entityType] || 0) + 1;
    }
    return {
      nodes: graphData.nodes.length,
      edges: graphData.edges.length,
      types: typeCounts,
    };
  }, [graphData]);

  return (
    <Layout>
      <div className="p-6 space-y-4 h-[calc(100vh-48px)] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between shrink-0">
          <div>
            <h1 className="text-2xl font-display font-semibold text-foreground">
              Knowledge Graph Explorer
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              Visualize relationships between equipment, failures, and documents
            </p>
          </div>
          <div className="flex items-center gap-2">
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <input
                data-ocid="graph.search_input"
                type="text"
                placeholder="Search entities..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 pr-3 py-2 rounded-md bg-card border border-input text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring w-48"
              />
            </div>
            <Button
              data-ocid="graph.zoom_in"
              variant="outline"
              size="icon"
              onClick={() => zoomIn()}
              title="Zoom In"
            >
              <ZoomIn className="w-4 h-4" />
            </Button>
            <Button
              data-ocid="graph.zoom_out"
              variant="outline"
              size="icon"
              onClick={() => zoomOut()}
              title="Zoom Out"
            >
              <ZoomOut className="w-4 h-4" />
            </Button>
            <Button
              data-ocid="graph.fit_view"
              variant="outline"
              size="icon"
              onClick={handleFitView}
              title="Fit View"
            >
              <RotateCcw className="w-4 h-4" />
            </Button>
          </div>
        </div>

        {/* Main graph area */}
        <div className="flex-1 flex gap-4 min-h-0">
          <Card className="flex-1 min-h-0 relative overflow-hidden">
            <CardContent className="p-0 h-full">
              {isLoading ? (
                <div className="h-full flex items-center justify-center">
                  <div className="space-y-2">
                    <Skeleton className="w-32 h-8" />
                    <Skeleton className="w-48 h-4" />
                  </div>
                </div>
              ) : (
                <ReactFlow
                  data-ocid="graph.canvas"
                  nodes={filteredNodes}
                  edges={filteredEdges}
                  onNodesChange={onNodesChange}
                  onEdgesChange={onEdgesChange}
                  onNodeClick={onNodeClick}
                  onPaneClick={onPaneClick}
                  nodeTypes={nodeTypes}
                  fitView
                  fitViewOptions={{ padding: 0.2 }}
                  minZoom={0.2}
                  maxZoom={2}
                  proOptions={{ hideAttribution: true }}
                >
                  <Background color="oklch(var(--border))" gap={20} size={1} />
                  <Controls
                    className="!bg-card !border-border !shadow-subtle"
                    showInteractive={false}
                  />
                </ReactFlow>
              )}
            </CardContent>
          </Card>

          {/* Right sidebar */}
          <div className="w-80 shrink-0 space-y-4 overflow-y-auto">
            {/* Legend */}
            <Card>
              <CardHeader>
                <CardTitle className="text-sm">Legend</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                {Object.entries(entityTypeColors).map(([type, color]) => (
                  <div key={type} className="flex items-center gap-2">
                    <span
                      className="w-3 h-3 rounded-full shrink-0"
                      style={{ backgroundColor: color }}
                    />
                    <Badge variant="outline" className="text-xs capitalize">
                      {type}
                    </Badge>
                  </div>
                ))}
              </CardContent>
            </Card>

            {/* Stats */}
            <Card>
              <CardHeader>
                <CardTitle className="text-sm">Graph Stats</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {isLoading ? (
                  <>
                    <Skeleton className="w-full h-4" />
                    <Skeleton className="w-full h-4" />
                  </>
                ) : stats ? (
                  <>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-muted-foreground">
                        Nodes
                      </span>
                      <span className="text-sm font-medium">{stats.nodes}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-muted-foreground">
                        Edges
                      </span>
                      <span className="text-sm font-medium">{stats.edges}</span>
                    </div>
                    {Object.entries(stats.types).map(([type, count]) => (
                      <div
                        key={type}
                        className="flex items-center justify-between"
                      >
                        <span className="text-sm text-muted-foreground capitalize">
                          {type}
                        </span>
                        <span className="text-sm font-medium">{count}</span>
                      </div>
                    ))}
                  </>
                ) : null}
              </CardContent>
            </Card>

            {/* Selected node detail panel */}
            {selectedNode && (
              <Card
                data-ocid="graph.detail_panel"
                className="border-primary/30"
              >
                <CardHeader className="pb-2">
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-sm">Entity Details</CardTitle>
                    <Button
                      data-ocid="graph.close_panel"
                      variant="ghost"
                      size="icon"
                      className="h-6 w-6"
                      onClick={() => setSelectedNode(null)}
                    >
                      <X className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div>
                    <p className="text-xs text-muted-foreground uppercase tracking-wide">
                      Name
                    </p>
                    <p className="text-sm font-medium text-foreground mt-0.5">
                      {selectedNode.data.label as string}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground uppercase tracking-wide">
                      Type
                    </p>
                    <Badge
                      variant="outline"
                      className="mt-0.5 capitalize"
                      style={{
                        borderColor:
                          entityTypeColors[selectedNode.data.type as string],
                        color:
                          entityTypeColors[selectedNode.data.type as string],
                      }}
                    >
                      {selectedNode.data.type as string}
                    </Badge>
                  </div>
                  {(() => {
                    const properties = selectedNode.data.properties as
                      | [string, string][]
                      | undefined;
                    if (
                      properties &&
                      Array.isArray(properties) &&
                      properties.length > 0
                    ) {
                      return (
                        <div>
                          <p className="text-xs text-muted-foreground uppercase tracking-wide">
                            Properties
                          </p>
                          <div className="mt-1 space-y-1">
                            {properties.map(([key, value]) => (
                              <div
                                key={key}
                                className="flex items-center justify-between text-xs"
                              >
                                <span className="text-muted-foreground">
                                  {key}
                                </span>
                                <span className="text-foreground font-medium truncate max-w-[140px]">
                                  {value}
                                </span>
                              </div>
                            ))}
                          </div>
                        </div>
                      );
                    }
                    return null;
                  })()}

                  {/* Connected entities */}
                  <ConnectedEntitiesPanel nodeId={selectedNode.id} />
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

function ConnectedEntitiesPanel({ nodeId }: { nodeId: string }) {
  const { data: graphData } = useGraphData(null, 2n);

  const connected = useMemo(() => {
    if (!graphData) return [];
    const rels = graphData.edges.filter(
      (e: GraphEdge) =>
        String(e.source) === nodeId || String(e.target) === nodeId,
    );
    return rels.map((e: GraphEdge) => {
      const isSource = String(e.source) === nodeId;
      const otherId = isSource ? String(e.target) : String(e.source);
      const otherNode = graphData.nodes.find(
        (n: GraphNode) => String(n.id) === otherId,
      );
      return {
        relationship: e.edgeLabel,
        direction: isSource ? "→" : "←",
        node: otherNode,
      };
    });
  }, [graphData, nodeId]);

  if (connected.length === 0) return null;

  return (
    <div>
      <p className="text-xs text-muted-foreground uppercase tracking-wide mb-2">
        Connected Entities
      </p>
      <div className="space-y-1.5">
        {connected.map((c, i) =>
          c.node ? (
            <div
              key={`conn-${c.node.id}-${i}`}
              className="flex items-center gap-2 text-xs p-1.5 rounded-md bg-muted/40"
            >
              <span
                className="w-2 h-2 rounded-full shrink-0"
                style={{
                  backgroundColor:
                    entityTypeColors[c.node.entityType] ||
                    entityTypeColors.other,
                }}
              />
              <span className="text-muted-foreground shrink-0">
                {c.direction}
              </span>
              <span className="truncate font-medium">{c.node.nodeLabel}</span>
              <span className="text-muted-foreground ml-auto shrink-0">
                {c.relationship}
              </span>
            </div>
          ) : null,
        )}
      </div>
    </div>
  );
}

function GraphPageWrapper() {
  return (
    <ReactFlowProvider>
      <GraphPage />
    </ReactFlowProvider>
  );
}
