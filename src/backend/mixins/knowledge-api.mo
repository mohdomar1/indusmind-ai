import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Runtime "mo:core/Runtime";
import AccessControl "mo:caffeineai-authorization/access-control";
import Types "../types/knowledge";
import Common "../types/common";
import KnowledgeLib "../lib/knowledge";

mixin (
  accessControlState : AccessControl.AccessControlState,
  entities : Map.Map<Common.EntityId, Types.Entity>,
  relationships : Map.Map<Common.RelationshipId, Types.Relationship>,
  nextEntityId : { var value : Nat },
  nextRelationshipId : { var value : Nat },
) {
  public shared ({ caller }) func createEntity(
    name : Text,
    entityType : Types.EntityType,
    properties : [(Text, Text)],
    sourceDocumentId : ?Common.DocumentId,
  ) : async Common.Result<Types.Entity, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextEntityId.value;
    nextEntityId.value += 1;
    KnowledgeLib.createEntity(entities, id, name, entityType, properties, sourceDocumentId);
  };

  public query ({ caller }) func getEntities(entityType : ?Types.EntityType) : async [Types.Entity] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    KnowledgeLib.getEntities(entities, entityType);
  };

  public shared ({ caller }) func createRelationship(
    sourceId : Common.EntityId,
    targetId : Common.EntityId,
    relationshipType : Types.RelationshipType,
    confidence : Float,
    sourceDocumentId : ?Common.DocumentId,
  ) : async Common.Result<Types.Relationship, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextRelationshipId.value;
    nextRelationshipId.value += 1;
    KnowledgeLib.createRelationship(relationships, id, sourceId, targetId, relationshipType, confidence, sourceDocumentId);
  };

  public query ({ caller }) func getRelationships(entityId : ?Common.EntityId) : async [Types.Relationship] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    KnowledgeLib.getRelationships(relationships, entityId);
  };

  public query ({ caller }) func getGraphData(
    centerEntityId : ?Common.EntityId,
    depth : Nat,
  ) : async Types.GraphData {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    KnowledgeLib.getGraphData(entities, relationships, centerEntityId, depth);
  };
};
