import Common "common";

module {
  public type IncidentId = Common.IncidentId;
  public type ComplianceCheckId = Common.ComplianceCheckId;
  public type Timestamp = Common.Timestamp;

  public type RootCauseResult = {
    userQuery : Text;
    equipmentId : ?Text;
    likelyCauses : [CauseAnalysis];
    similarFailures : [SimilarFailure];
    evidence : [EvidenceItem];
    confidenceScore : Float;
    recommendedActions : [Text];
    generatedAt : Timestamp;
  };

  public type CauseAnalysis = {
    cause : Text;
    probability : Float;
    supportingEvidence : [Text];
  };

  public type SimilarFailure = {
    incidentId : IncidentId;
    description : Text;
    equipmentId : Text;
    date : Text;
    similarityScore : Float;
  };

  public type EvidenceItem = {
    documentId : Common.DocumentId;
    documentName : Text;
    excerpt : Text;
    relevanceScore : Float;
  };

  public type ComplianceResult = {
    checkId : ComplianceCheckId;
    documentId : Common.DocumentId;
    complianceScore : Float;
    gaps : [ComplianceGap];
    violations : [ComplianceViolation];
    riskLevel : RiskLevel;
    suggestedCorrections : [Text];
    generatedAt : Timestamp;
  };

  public type ComplianceGap = {
    requirement : Text;
    missingIn : Text;
    severity : Severity;
  };

  public type ComplianceViolation = {
    rule : Text;
    violation : Text;
    location : Text;
    severity : Severity;
  };

  public type RiskLevel = {
    #low;
    #medium;
    #high;
    #critical;
  };

  public type Severity = {
    #minor;
    #moderate;
    #major;
    #critical;
  };

  public type LessonsLearnedResult = {
    analysisId : Nat;
    patterns : [PatternDetection];
    highRiskConditions : [RiskCondition];
    preventiveActions : [PreventiveAction];
    generatedAt : Timestamp;
  };

  public type PatternDetection = {
    patternName : Text;
    occurrenceCount : Nat;
    affectedEquipment : [Text];
    description : Text;
  };

  public type RiskCondition = {
    condition : Text;
    riskLevel : RiskLevel;
    historicalIncidents : [IncidentId];
    recommendation : Text;
  };

  public type PreventiveAction = {
    action : Text;
    priority : Priority;
    estimatedImpact : Text;
  };

  public type Priority = {
    #low;
    #medium;
    #high;
    #urgent;
  };

  public type IncidentRecord = {
    id : IncidentId;
    title : Text;
    description : Text;
    equipmentId : ?Text;
    incidentType : Text;
    severity : Severity;
    date : Text;
    sourceDocumentId : ?Common.DocumentId;
    createdAt : Timestamp;
  };

  public type ComplianceFinding = {
    id : ComplianceCheckId;
    documentId : Common.DocumentId;
    findingType : Text;
    description : Text;
    severity : Severity;
    status : FindingStatus;
    createdAt : Timestamp;
  };

  public type FindingStatus = {
    #open;
    #inReview;
    #resolved;
    #dismissed;
  };
};
