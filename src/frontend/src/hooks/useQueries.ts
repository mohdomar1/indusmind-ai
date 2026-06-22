import { createActor } from "@/backend";
import type {
  ActivityItem,
  ChatMessage,
  ChatThread,
  ComplianceResult,
  DashboardStats,
  Document,
  DocumentChunk,
  DocumentSummary,
  Entity,
  ExternalBlob,
  GraphData,
  LessonsLearnedResult,
  MessageRole,
  Relationship,
  RootCauseResult,
} from "@/backend";
import { useActor } from "@caffeineai/core-infrastructure";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

// Dashboard
export function useDashboardStats() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<DashboardStats>({
    queryKey: ["dashboard", "stats"],
    queryFn: async () => {
      if (!actor) throw new Error("Actor not available");
      return actor.getDashboardStats();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useRecentActivity(limit = 10n) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<ActivityItem[]>({
    queryKey: ["dashboard", "activity", String(limit)],
    queryFn: async () => {
      if (!actor) throw new Error("Actor not available");
      return actor.getRecentActivity(limit);
    },
    enabled: !!actor && !isFetching,
  });
}

// Documents
export function useDocuments() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<DocumentSummary[]>({
    queryKey: ["documents"],
    queryFn: async () => {
      if (!actor) throw new Error("Actor not available");
      return actor.getDocuments();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useDocument(id: bigint | null) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<Document | null>({
    queryKey: ["document", id?.toString()],
    queryFn: async () => {
      if (!actor || id === null) return null;
      const res = await actor.getDocument(id);
      if (res.__kind__ === "ok") return res.ok;
      return null;
    },
    enabled: !!actor && !isFetching && id !== null,
  });
}

export function useUploadDocument() {
  const queryClient = useQueryClient();
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (params: {
      filename: string;
      mimeType: string;
      blob: ExternalBlob;
      fileSize: bigint;
    }) => {
      if (!actor) throw new Error("Actor not available");
      const res = await actor.uploadDocument(
        params.filename,
        params.mimeType,
        params.blob,
        params.fileSize,
      );
      if (res.__kind__ === "err") throw new Error(String(res.err));
      return res.ok;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["documents"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard", "stats"] });
    },
  });
}

export function useDeleteDocument() {
  const queryClient = useQueryClient();
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (id: bigint) => {
      if (!actor) throw new Error("Actor not available");
      const res = await actor.deleteDocument(id);
      if (res.__kind__ === "err") throw new Error(String(res.err));
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["documents"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard", "stats"] });
    },
  });
}

// Chat / Copilot
export function useChatThreads() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<ChatThread[]>({
    queryKey: ["chat", "threads"],
    queryFn: async () => {
      if (!actor) throw new Error("Actor not available");
      return actor.getChatThreads();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useChatMessages(threadId: bigint | null) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<ChatMessage[]>({
    queryKey: ["chat", "messages", threadId?.toString()],
    queryFn: async () => {
      if (!actor || threadId === null) return [];
      return actor.getChatMessages(threadId);
    },
    enabled: !!actor && !isFetching && threadId !== null,
  });
}

export function useCreateChatThread() {
  const queryClient = useQueryClient();
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (title: string) => {
      if (!actor) throw new Error("Actor not available");
      return actor.createChatThread(title);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["chat", "threads"] });
    },
  });
}

export function useSendMessage() {
  const queryClient = useQueryClient();
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (params: {
      threadId: bigint;
      role: MessageRole;
      content: string;
      sources: {
        documentId: bigint;
        documentName: string;
        excerpt: string;
        chunkIndex: bigint;
      }[];
      confidence: number | null;
    }) => {
      if (!actor) throw new Error("Actor not available");
      const sources = params.sources.map((s) => ({
        documentId: s.documentId,
        documentName: s.documentName,
        excerpt: s.excerpt,
        chunkIndex: s.chunkIndex,
      }));
      const res = await actor.sendMessage(
        params.threadId,
        params.role,
        params.content,
        sources,
        params.confidence,
      );
      if (res.__kind__ === "err") throw new Error(String(res.err));
      return res.ok;
    },
    onSuccess: (_, vars) => {
      queryClient.invalidateQueries({
        queryKey: ["chat", "messages", vars.threadId.toString()],
      });
    },
  });
}

// Analysis
export function useRootCauseAnalysis() {
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (params: {
      userQuery: string;
      equipmentId: string | null;
    }) => {
      if (!actor) throw new Error("Actor not available");
      const res = await actor.runRootCauseAnalysis(
        params.userQuery,
        params.equipmentId,
      );
      return res as RootCauseResult;
    },
  });
}

export function useComplianceCheck() {
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (documentId: bigint) => {
      if (!actor) throw new Error("Actor not available");
      const res = await actor.runComplianceCheck(documentId);
      if (res.__kind__ === "err") throw new Error(String(res.err));
      return res.ok as ComplianceResult;
    },
  });
}

export function useLessonsLearnedAnalysis() {
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async () => {
      if (!actor) throw new Error("Actor not available");
      return actor.runLessonsLearnedAnalysis();
    },
  });
}

// Knowledge Graph
export function useEntities(entityType: string | null) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<Entity[]>({
    queryKey: ["entities", entityType],
    queryFn: async () => {
      if (!actor) return [];
      // backend expects EntityType enum or null
      return actor.getEntities(entityType as any);
    },
    enabled: !!actor && !isFetching,
  });
}

export function useRelationships(entityId: bigint | null) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<Relationship[]>({
    queryKey: ["relationships", entityId?.toString()],
    queryFn: async () => {
      if (!actor || entityId === null) return [];
      return actor.getRelationships(entityId);
    },
    enabled: !!actor && !isFetching && entityId !== null,
  });
}

export function useGraphData(centerEntityId: bigint | null, depth = 2n) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery<GraphData>({
    queryKey: ["graph", centerEntityId?.toString(), String(depth)],
    queryFn: async () => {
      if (!actor) return { nodes: [], edges: [] };
      return actor.getGraphData(centerEntityId, depth);
    },
    enabled: !!actor && !isFetching,
  });
}

// Semantic Search
export function useSemanticSearch() {
  const { actor } = useActor(createActor);
  return useMutation({
    mutationFn: async (params: { searchQuery: string; limit: bigint }) => {
      if (!actor) throw new Error("Actor not available");
      return actor.semanticSearch(params.searchQuery, params.limit);
    },
  });
}
