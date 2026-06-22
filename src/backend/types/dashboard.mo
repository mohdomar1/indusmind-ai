import Common "common";

module {
  public type Timestamp = Common.Timestamp;

  public type DashboardStats = {
    totalDocuments : Nat;
    documentsProcessed : Nat;
    totalEntities : Nat;
    totalRelationships : Nat;
    totalChatThreads : Nat;
    totalIncidents : Nat;
    totalComplianceChecks : Nat;
    recentUploads : Nat;
  };

  public type ActivityItem = {
    id : Nat;
    activityType : ActivityType;
    description : Text;
    timestamp : Timestamp;
    relatedDocumentId : ?Common.DocumentId;
  };

  public type ActivityType = {
    #documentUploaded;
    #documentProcessed;
    #entityExtracted;
    #relationshipCreated;
    #chatCreated;
    #analysisRun;
    #complianceChecked;
    #incidentRecorded;
  };
};
