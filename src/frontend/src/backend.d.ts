import type { Principal } from "@icp-sdk/core/principal";
export interface Some<T> {
    __kind__: "Some";
    value: T;
}
export interface None {
    __kind__: "None";
}
export type Option<T> = Some<T> | None;
export class ExternalBlob {
    getBytes(): Promise<Uint8Array<ArrayBuffer>>;
    getDirectURL(): string;
    static fromURL(url: string): ExternalBlob;
    static fromBytes(blob: Uint8Array<ArrayBuffer>): ExternalBlob;
    withUploadProgress(onProgress: (percentage: number) => void): ExternalBlob;
}
export interface RootCauseResult {
    userQuery: string;
    recommendedActions: Array<string>;
    generatedAt: Timestamp;
    similarFailures: Array<SimilarFailure>;
    confidenceScore: number;
    evidence: Array<EvidenceItem>;
    equipmentId?: string;
    likelyCauses: Array<CauseAnalysis>;
}
export type Result_2 = {
    __kind__: "ok";
    ok: ComplianceResult;
} | {
    __kind__: "err";
    err: AppError;
};
export type IncidentId = bigint;
export interface DocumentSummary {
    id: DocumentId;
    status: DocumentStatus;
    createdAt: Timestamp;
    mimeType: string;
    filename: string;
}
export type EntityId = bigint;
export interface Document {
    id: DocumentId;
    status: DocumentStatus;
    owner: Principal;
    metadata: DocumentMetadata;
    blob: ExternalBlob;
    createdAt: Timestamp;
    mimeType: string;
    extractedText?: string;
    filename: string;
    updatedAt: Timestamp;
}
export type Result__1 = {
    __kind__: "ok";
    ok: null;
} | {
    __kind__: "err";
    err: Error_;
};
export type Result_5 = {
    __kind__: "ok";
    ok: null;
} | {
    __kind__: "err";
    err: AppError;
};
export interface SimilarFailure {
    incidentId: IncidentId;
    date: string;
    similarityScore: number;
    description: string;
    equipmentId: string;
}
export type Result_4 = {
    __kind__: "ok";
    ok: ComplianceFinding;
} | {
    __kind__: "err";
    err: AppError;
};
export interface ChatThread {
    id: ChatThreadId;
    title: string;
    owner: Principal;
    createdAt: Timestamp;
    updatedAt: Timestamp;
}
export interface RiskCondition {
    historicalIncidents: Array<IncidentId>;
    recommendation: string;
    riskLevel: RiskLevel;
    condition: string;
}
export type Result_7 = {
    __kind__: "ok";
    ok: Entity;
} | {
    __kind__: "err";
    err: AppError;
};
export interface ComplianceResult {
    checkId: ComplianceCheckId;
    gaps: Array<ComplianceGap>;
    generatedAt: Timestamp;
    violations: Array<ComplianceViolation>;
    documentId: DocumentId;
    complianceScore: number;
    riskLevel: RiskLevel;
    suggestedCorrections: Array<string>;
}
export type ComplianceCheckId = bigint;
export interface ChatMessage {
    id: ChatMessageId;
    content: string;
    createdAt: Timestamp;
    role: MessageRole;
    sources: Array<SourceCitation>;
    confidence?: number;
    threadId: ChatThreadId;
}
export interface DocumentChunk {
    id: ChunkId;
    content: string;
    chunkIndex: bigint;
    createdAt: Timestamp;
    embedding?: Array<number>;
    documentId: DocumentId;
}
export interface ActivityItem {
    id: bigint;
    activityType: ActivityType;
    relatedDocumentId?: DocumentId;
    description: string;
    timestamp: Timestamp;
}
export interface PatternDetection {
    occurrenceCount: bigint;
    patternName: string;
    description: string;
    affectedEquipment: Array<string>;
}
export interface ComplianceFinding {
    id: ComplianceCheckId;
    status: FindingStatus;
    createdAt: Timestamp;
    description: string;
    documentId: DocumentId;
    severity: Severity;
    findingType: string;
}
export type Result_6 = {
    __kind__: "ok";
    ok: Relationship;
} | {
    __kind__: "err";
    err: AppError;
};
export type ChatMessageId = bigint;
export interface LessonsLearnedResult {
    patterns: Array<PatternDetection>;
    generatedAt: Timestamp;
    preventiveActions: Array<PreventiveAction>;
    analysisId: bigint;
    highRiskConditions: Array<RiskCondition>;
}
export type Result_9 = {
    __kind__: "ok";
    ok: Array<DocumentChunk>;
} | {
    __kind__: "err";
    err: AppError;
};
export type Error_ = {
    __kind__: "FrontendOriginsNotConfigured";
    FrontendOriginsNotConfigured: null;
} | {
    __kind__: "MixedSsoSources";
    MixedSsoSources: {
        otherKeys: Array<string>;
        ssoKeys: Array<string>;
    };
} | {
    __kind__: "Stale";
    Stale: {
        ageNs: bigint;
    };
} | {
    __kind__: "MalformedCandid";
    MalformedCandid: null;
} | {
    __kind__: "AmbiguousAttribute";
    AmbiguousAttribute: {
        field: string;
        sources: Array<string>;
    };
} | {
    __kind__: "NoAttributes";
    NoAttributes: null;
} | {
    __kind__: "UnknownNonce";
    UnknownNonce: null;
} | {
    __kind__: "UntrustedSsoSource";
    UntrustedSsoSource: {
        domain: string;
    };
} | {
    __kind__: "MissingField";
    MissingField: string;
} | {
    __kind__: "FrontendOriginMismatch";
    FrontendOriginMismatch: {
        got: string;
        expected: Array<string>;
    };
};
export interface DashboardStats {
    totalChatThreads: bigint;
    totalComplianceChecks: bigint;
    recentUploads: bigint;
    totalEntities: bigint;
    totalIncidents: bigint;
    totalDocuments: bigint;
    documentsProcessed: bigint;
    totalRelationships: bigint;
}
export interface SourceCitation {
    documentName: string;
    chunkIndex: bigint;
    excerpt: string;
    documentId: DocumentId;
}
export type Result = {
    __kind__: "ok";
    ok: Document;
} | {
    __kind__: "err";
    err: AppError;
};
export interface GraphData {
    edges: Array<GraphEdge>;
    nodes: Array<GraphNode>;
}
export type Result_8 = {
    __kind__: "ok";
    ok: DocumentChunk;
} | {
    __kind__: "err";
    err: AppError;
};
export interface IncidentRecord {
    id: IncidentId;
    title: string;
    sourceDocumentId?: DocumentId;
    date: string;
    createdAt: Timestamp;
    description: string;
    severity: Severity;
    equipmentId?: string;
    incidentType: string;
}
export interface ComplianceGap {
    requirement: string;
    missingIn: string;
    severity: Severity;
}
export type Timestamp = bigint;
export type ChatThreadId = bigint;
export interface DocumentMetadata {
    assetNames: Array<string>;
    fileSize: bigint;
    personnel: Array<string>;
    failureTypes: Array<string>;
    maintenanceEvents: Array<string>;
    safetyReferences: Array<string>;
    dates: Array<string>;
    pageCount?: bigint;
    equipmentIds: Array<string>;
    regulatoryReferences: Array<string>;
}
export type ChunkId = bigint;
export type Result_1 = {
    __kind__: "ok";
    ok: ChatMessage;
} | {
    __kind__: "err";
    err: AppError;
};
export interface GraphNode {
    id: EntityId;
    nodeLabel: string;
    properties: Array<[string, string]>;
    entityType: EntityType;
}
export interface EvidenceItem {
    documentName: string;
    relevanceScore: number;
    excerpt: string;
    documentId: DocumentId;
}
export interface Entity {
    id: EntityId;
    sourceDocumentId?: DocumentId;
    name: string;
    createdAt: Timestamp;
    properties: Array<[string, string]>;
    entityType: EntityType;
}
export interface ComplianceViolation {
    violation: string;
    rule: string;
    severity: Severity;
    location: string;
}
export type DocumentId = bigint;
export type RelationshipId = bigint;
export interface PreventiveAction {
    action: string;
    estimatedImpact: string;
    priority: Priority;
}
export interface GraphEdge {
    id: RelationshipId;
    source: EntityId;
    target: EntityId;
    edgeLabel: string;
    confidence: number;
    relationshipType: RelationshipType;
}
export type Result_3 = {
    __kind__: "ok";
    ok: IncidentRecord;
} | {
    __kind__: "err";
    err: AppError;
};
export interface CauseAnalysis {
    probability: number;
    cause: string;
    supportingEvidence: Array<string>;
}
export interface Relationship {
    id: RelationshipId;
    sourceDocumentId?: DocumentId;
    createdAt: Timestamp;
    sourceId: EntityId;
    confidence: number;
    targetId: EntityId;
    relationshipType: RelationshipType;
}
export enum ActivityType {
    documentUploaded = "documentUploaded",
    complianceChecked = "complianceChecked",
    entityExtracted = "entityExtracted",
    relationshipCreated = "relationshipCreated",
    chatCreated = "chatCreated",
    documentProcessed = "documentProcessed",
    incidentRecorded = "incidentRecorded",
    analysisRun = "analysisRun"
}
export enum AppError {
    storageError = "storageError",
    processingError = "processingError",
    alreadyExists = "alreadyExists",
    invalidInput = "invalidInput",
    notFound = "notFound",
    unauthorized = "unauthorized"
}
export enum DocumentStatus {
    chunked = "chunked",
    error = "error",
    extracted = "extracted",
    uploaded = "uploaded",
    processing = "processing",
    embedded = "embedded",
    ready = "ready"
}
export enum EntityType {
    failure = "failure",
    asset = "asset",
    regulation = "regulation",
    other = "other",
    equipment = "equipment",
    person = "person",
    event = "event",
    document_ = "document",
    procedure = "procedure",
    location = "location"
}
export enum FindingStatus {
    resolved = "resolved",
    open = "open",
    inReview = "inReview",
    dismissed = "dismissed"
}
export enum MessageRole {
    user = "user",
    assistant = "assistant"
}
export enum Priority {
    low = "low",
    high = "high",
    urgent = "urgent",
    medium = "medium"
}
export enum RelationshipType {
    leadsTo = "leadsTo",
    references = "references",
    other = "other",
    violates = "violates",
    inspectedBy = "inspectedBy",
    similarTo = "similarTo",
    compliesWith = "compliesWith",
    maintainedBy = "maintainedBy",
    locatedAt = "locatedAt",
    causes = "causes",
    partOf = "partOf"
}
export enum RiskLevel {
    low = "low",
    high = "high",
    critical = "critical",
    medium = "medium"
}
export enum Severity {
    major = "major",
    minor = "minor",
    critical = "critical",
    moderate = "moderate"
}
export enum UserRole {
    admin = "admin",
    user = "user",
    guest = "guest"
}
export interface backendInterface {
    assignCallerUserRole(user: Principal, role: UserRole): Promise<void>;
    createChatThread(title: string): Promise<ChatThread>;
    createChunks(documentId: DocumentId, chunkContents: Array<string>): Promise<Result_9>;
    createEmbedding(chunkId: ChunkId, embedding: Array<number>): Promise<Result_8>;
    createEntity(name: string, entityType: EntityType, properties: Array<[string, string]>, sourceDocumentId: DocumentId | null): Promise<Result_7>;
    createRelationship(sourceId: EntityId, targetId: EntityId, relationshipType: RelationshipType, confidence: number, sourceDocumentId: DocumentId | null): Promise<Result_6>;
    deleteDocument(id: DocumentId): Promise<Result_5>;
    extractText(id: DocumentId, extractedText: string): Promise<Result>;
    getCallerUserRole(): Promise<UserRole>;
    getChatMessages(threadId: ChatThreadId): Promise<Array<ChatMessage>>;
    getChatThreads(): Promise<Array<ChatThread>>;
    getDashboardStats(): Promise<DashboardStats>;
    getDocument(id: DocumentId): Promise<Result>;
    getDocuments(): Promise<Array<DocumentSummary>>;
    getEntities(entityType: EntityType | null): Promise<Array<Entity>>;
    getGraphData(centerEntityId: EntityId | null, depth: bigint): Promise<GraphData>;
    getRecentActivity(limit: bigint): Promise<Array<ActivityItem>>;
    getRelationships(entityId: EntityId | null): Promise<Array<Relationship>>;
    isCallerAdmin(): Promise<boolean>;
    recordComplianceFinding(documentId: DocumentId, findingType: string, description: string, severity: Severity, status: FindingStatus): Promise<Result_4>;
    recordIncident(title: string, description: string, equipmentId: string | null, incidentType: string, severity: Severity, date: string, sourceDocumentId: DocumentId | null): Promise<Result_3>;
    runComplianceCheck(documentId: DocumentId): Promise<Result_2>;
    runLessonsLearnedAnalysis(): Promise<LessonsLearnedResult>;
    runRootCauseAnalysis(userQuery: string, equipmentId: string | null): Promise<RootCauseResult>;
    semanticSearch(searchQuery: string, limit: bigint): Promise<Array<DocumentChunk>>;
    sendMessage(threadId: ChatThreadId, role: MessageRole, content: string, sources: Array<SourceCitation>, confidence: number | null): Promise<Result_1>;
    uploadDocument(filename: string, mimeType: string, blob: ExternalBlob, fileSize: bigint): Promise<Result>;
}
