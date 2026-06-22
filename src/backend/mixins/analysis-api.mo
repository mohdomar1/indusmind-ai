import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Runtime "mo:core/Runtime";
import AccessControl "mo:caffeineai-authorization/access-control";
import Types "../types/analysis";
import Common "../types/common";
import AnalysisLib "../lib/analysis";
import KnowledgeTypes "../types/knowledge";
import DocumentTypes "../types/documents";

mixin (
  accessControlState : AccessControl.AccessControlState,
  incidents : Map.Map<Common.IncidentId, Types.IncidentRecord>,
  findings : Map.Map<Common.ComplianceCheckId, Types.ComplianceFinding>,
  entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
  relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
  documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
  nextIncidentId : { var value : Nat },
  nextCheckId : { var value : Nat },
  nextAnalysisId : { var value : Nat }
) {
  public shared ({ caller }) func runRootCauseAnalysis(
    userQuery : Text,
    equipmentId : ?Text,
  ) : async Types.RootCauseResult {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    AnalysisLib.runRootCauseAnalysis(incidents, entities, relationships, documents, userQuery, equipmentId, nextAnalysisId);
  };

  public shared ({ caller }) func runComplianceCheck(
    documentId : Common.DocumentId,
  ) : async Common.Result<Types.ComplianceResult, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    AnalysisLib.runComplianceCheck(findings, documents, documentId, nextCheckId);
  };

  public shared ({ caller }) func runLessonsLearnedAnalysis() : async Types.LessonsLearnedResult {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    AnalysisLib.runLessonsLearnedAnalysis(incidents, findings, entities, nextAnalysisId);
  };

  public shared ({ caller }) func recordIncident(
    title : Text,
    description : Text,
    equipmentId : ?Text,
    incidentType : Text,
    severity : Types.Severity,
    date : Text,
    sourceDocumentId : ?Common.DocumentId,
  ) : async Common.Result<Types.IncidentRecord, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextIncidentId.value;
    nextIncidentId.value += 1;
    AnalysisLib.recordIncident(incidents, id, title, description, equipmentId, incidentType, severity, date, sourceDocumentId);
  };

  public shared ({ caller }) func recordComplianceFinding(
    documentId : Common.DocumentId,
    findingType : Text,
    description : Text,
    severity : Types.Severity,
    status : Types.FindingStatus,
  ) : async Common.Result<Types.ComplianceFinding, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextCheckId.value;
    nextCheckId.value += 1;
    AnalysisLib.recordComplianceFinding(findings, id, documentId, findingType, description, severity, status);
  };
};
