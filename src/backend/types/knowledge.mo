import Common "common";

module {
  public type EntityId = Common.EntityId;
  public type RelationshipId = Common.RelationshipId;
  public type Timestamp = Common.Timestamp;

  public type EntityType = {
    #equipment;
    #asset;
    #person;
    #location;
    #event;
    #failure;
    #procedure;
    #regulation;
    #document;
    #other;
  };

  public type Entity = {
    id : EntityId;
    name : Text;
    entityType : EntityType;
    properties : [(Text, Text)];
    sourceDocumentId : ?Common.DocumentId;
    createdAt : Timestamp;
  };

  public type RelationshipType = {
    #causes;
    #locatedAt;
    #maintainedBy;
    #inspectedBy;
    #references;
    #partOf;
    #leadsTo;
    #similarTo;
    #compliesWith;
    #violates;
    #other;
  };

  public type Relationship = {
    id : RelationshipId;
    sourceId : EntityId;
    targetId : EntityId;
    relationshipType : RelationshipType;
    confidence : Float;
    sourceDocumentId : ?Common.DocumentId;
    createdAt : Timestamp;
  };

  public type GraphNode = {
    id : EntityId;
    nodeLabel : Text;
    entityType : EntityType;
    properties : [(Text, Text)];
  };

  public type GraphEdge = {
    id : RelationshipId;
    source : EntityId;
    target : EntityId;
    edgeLabel : Text;
    relationshipType : RelationshipType;
    confidence : Float;
  };

  public type GraphData = {
    nodes : [GraphNode];
    edges : [GraphEdge];
  };
};
