import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Types "../types/knowledge";
import Common "../types/common";
import Time "mo:core/Time";
import List "mo:core/List";
import Int "mo:core/Int";

module {
  public type Entity = Types.Entity;
  public type Relationship = Types.Relationship;
  public type GraphData = Types.GraphData;
  public type GraphNode = Types.GraphNode;
  public type GraphEdge = Types.GraphEdge;
  public type Result<T> = Common.Result<T, Common.AppError>;

  public func createEntity(
    entities : Map.Map<Common.EntityId, Entity>,
    id : Common.EntityId,
    name : Text,
    entityType : Types.EntityType,
    properties : [(Text, Text)],
    sourceDocumentId : ?Common.DocumentId,
  ) : Result<Entity> {
    let now = Int.abs(Time.now());
    let entity : Entity = {
      id = id;
      name = name;
      entityType = entityType;
      properties = properties;
      sourceDocumentId = sourceDocumentId;
      createdAt = now;
    };
    entities.add(id, entity);
    #ok entity;
  };

  public func getEntities(
    entities : Map.Map<Common.EntityId, Entity>,
    entityType : ?Types.EntityType,
  ) : [Entity] {
    let results = List.empty<Entity>();
    for ((_id, entity) in entities.entries()) {
      switch (entityType) {
        case (?et) {
          if (entity.entityType == et) {
            results.add(entity);
          };
        };
        case null {
          results.add(entity);
        };
      };
    };
    results.toArray();
  };

  public func createRelationship(
    relationships : Map.Map<Common.RelationshipId, Relationship>,
    id : Common.RelationshipId,
    sourceId : Common.EntityId,
    targetId : Common.EntityId,
    relationshipType : Types.RelationshipType,
    confidence : Float,
    sourceDocumentId : ?Common.DocumentId,
  ) : Result<Relationship> {
    let now = Int.abs(Time.now());
    let relationship : Relationship = {
      id = id;
      sourceId = sourceId;
      targetId = targetId;
      relationshipType = relationshipType;
      confidence = confidence;
      sourceDocumentId = sourceDocumentId;
      createdAt = now;
    };
    relationships.add(id, relationship);
    #ok relationship;
  };

  public func getRelationships(
    relationships : Map.Map<Common.RelationshipId, Relationship>,
    entityId : ?Common.EntityId,
  ) : [Relationship] {
    let results = List.empty<Relationship>();
    for ((_id, rel) in relationships.entries()) {
      switch (entityId) {
        case (?eid) {
          if (rel.sourceId == eid or rel.targetId == eid) {
            results.add(rel);
          };
        };
        case null {
          results.add(rel);
        };
      };
    };
    results.toArray();
  };

  public func getGraphData(
    entities : Map.Map<Common.EntityId, Entity>,
    relationships : Map.Map<Common.RelationshipId, Relationship>,
    centerEntityId : ?Common.EntityId,
    depth : Nat,
  ) : GraphData {
    ignore (centerEntityId, depth);
    let nodes = List.empty<GraphNode>();
    for ((_id, entity) in entities.entries()) {
      nodes.add({
        id = entity.id;
        nodeLabel = entity.name;
        entityType = entity.entityType;
        properties = entity.properties;
      });
    };
    let edges = List.empty<GraphEdge>();
    for ((_id, rel) in relationships.entries()) {
      edges.add({
        id = rel.id;
        source = rel.sourceId;
        target = rel.targetId;
        edgeLabel = switch (rel.relationshipType) {
          case (#causes) { "causes" };
          case (#locatedAt) { "locatedAt" };
          case (#maintainedBy) { "maintainedBy" };
          case (#inspectedBy) { "inspectedBy" };
          case (#references) { "references" };
          case (#partOf) { "partOf" };
          case (#leadsTo) { "leadsTo" };
          case (#similarTo) { "similarTo" };
          case (#compliesWith) { "compliesWith" };
          case (#violates) { "violates" };
          case (#other) { "other" };
        };
        relationshipType = rel.relationshipType;
        confidence = rel.confidence;
      });
    };
    {
      nodes = nodes.toArray();
      edges = edges.toArray();
    };
  };
};
