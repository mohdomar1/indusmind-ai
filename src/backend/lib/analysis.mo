import Debug "mo:core/Debug";
import Map "mo:core/Map";
import List "mo:core/List";
import Types "../types/analysis";
import Common "../types/common";
import KnowledgeTypes "../types/knowledge";
import DocumentTypes "../types/documents";
import Time "mo:core/Time";
import Int "mo:core/Int";

module {
  public type RootCauseResult = Types.RootCauseResult;
  public type ComplianceResult = Types.ComplianceResult;
  public type LessonsLearnedResult = Types.LessonsLearnedResult;
  public type IncidentRecord = Types.IncidentRecord;
  public type ComplianceFinding = Types.ComplianceFinding;
  public type Result<T> = Common.Result<T, Common.AppError>;

  public func runRootCauseAnalysis(
    incidents : Map.Map<Common.IncidentId, IncidentRecord>,
    entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
    relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
    userQuery : Text,
    equipmentId : ?Text,
    nextAnalysisId : { var value : Nat },
  ) : RootCauseResult {
    let now = Int.abs(Time.now());
    let queryLower = Text.toLower(userQuery);

    // Collect related incidents by equipmentId or keyword match
    let relatedIncidents = List.empty<IncidentRecord>();
    for ((_id, inc) in incidents.entries()) {
      let match = switch (equipmentId) {
        case (?eq) {
          switch (inc.equipmentId) {
            case (?incEq) { Text.toLower(incEq) == Text.toLower(eq) };
            case null { false };
          };
        };
        case null {
          Text.contains(Text.toLower(inc.title), #text queryLower) or
          Text.contains(Text.toLower(inc.description), #text queryLower);
        };
      };
      if (match) {
        relatedIncidents.add(inc);
      };
    };

    // Build likely causes from incident types and descriptions
    let likelyCauses = List.empty<Types.CauseAnalysis>();
    let causeSet = List.empty<Text>();
    for (inc in relatedIncidents.toArray().vals()) {
      let causeKey = Text.toLower(inc.incidentType);
      var alreadyAdded = false;
      for (existing in causeSet.toArray().vals()) {
        if (existing == causeKey) { alreadyAdded := true };
      };
      if (not alreadyAdded) {
        causeSet.add(causeKey);
        let probability = switch (inc.severity) {
          case (#critical) { 0.92 };
          case (#major) { 0.78 };
          case (#moderate) { 0.62 };
          case (#minor) { 0.45 };
        };
        likelyCauses.add({
          cause = inc.incidentType;
          probability = probability;
          supportingEvidence = [inc.description];
        });
      };
    };

    // Find similar failures (other incidents with same type)
    let similarFailures = List.empty<Types.SimilarFailure>();
    let relatedArray = relatedIncidents.toArray();
    for (primary in relatedArray.vals()) {
      for ((_id, other) in incidents.entries()) {
        if (other.id != primary.id and other.incidentType == primary.incidentType) {
          let eqId = switch (other.equipmentId) {
            case (?e) { e };
            case null { "Unknown" };
          };
          similarFailures.add({
            incidentId = other.id;
            description = other.title;
            equipmentId = eqId;
            date = other.date;
            similarityScore = 0.85;
          });
        };
      };
    };

    // Gather evidence from source documents
    let evidence = List.empty<Types.EvidenceItem>();
    for (inc in relatedIncidents.toArray().vals()) {
      switch (inc.sourceDocumentId) {
        case (?docId) {
          switch (documents.get(docId)) {
            case (?doc) {
              let excerpt = switch (doc.extractedText) {
                case (?text) {
                  if (text.size() > 200) {
                    let prefix = Text.concat("", text); // copy
                    // Truncate by taking first 200 chars manually
                    var truncated = "";
                    var count = 0;
                    for (char in prefix.chars()) {
                      if (count >= 200) { break };
                      truncated := Text.concat(truncated, Text.fromChar(char));
                      count += 1;
                    };
                    Text.concat(truncated, "...");
                  } else { text };
                };
                case null { "Document content not extracted" };
              };
              evidence.add({
                documentId = docId;
                documentName = doc.filename;
                excerpt = excerpt;
                relevanceScore = 0.9;
              });
            };
            case null {};
          };
        };
        case null {};
      };
    };

    // Build recommended actions based on incident patterns
    let recommendedActions = List.empty<Text>();
    for (inc in relatedIncidents.toArray().vals()) {
      let action = "Address " # inc.incidentType # " for equipment " # (switch (inc.equipmentId) { case (?e) { e }; case null { "unknown" } }) # ": " # inc.description;
      recommendedActions.add(action);
    };
    if (recommendedActions.size() == 0) {
      recommendedActions.add("No specific incidents found. Conduct preventive inspection.");
    };

    // Compute confidence based on data richness
    let incidentCount = relatedIncidents.size();
    let confidenceScore = if (incidentCount >= 3) { 0.92 }
      else if (incidentCount >= 2) { 0.78 }
      else if (incidentCount >= 1) { 0.65 }
      else { 0.35 };

    {
      userQuery = userQuery;
      equipmentId = equipmentId;
      likelyCauses = likelyCauses.toArray();
      similarFailures = similarFailures.toArray();
      evidence = evidence.toArray();
      confidenceScore = confidenceScore;
      recommendedActions = recommendedActions.toArray();
      generatedAt = now;
    }
  };

  public func runComplianceCheck(
    findings : Map.Map<Common.ComplianceCheckId, ComplianceFinding>,
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
    documentId : Common.DocumentId,
    nextCheckId : { var value : Nat },
  ) : Result<ComplianceResult> {
    let now = Int.abs(Time.now());

    // Get the target document
    let targetDoc = switch (documents.get(documentId)) {
      case (?doc) { doc };
      case null { return #err(#notFound) };
    };

    // Collect findings related to this document
    let docFindings = List.empty<ComplianceFinding>();
    for ((_id, finding) in findings.entries()) {
      if (finding.documentId == documentId) {
        docFindings.add(finding);
      };
    };

    // Also collect general regulatory findings
    let regFindings = List.empty<ComplianceFinding>();
    for ((_id, finding) in findings.entries()) {
      if (finding.documentId != documentId) {
        regFindings.add(finding);
      };
    };

    // Build gaps from findings
    let gaps = List.empty<Types.ComplianceGap>();
    let violations = List.empty<Types.ComplianceViolation>();
    var criticalCount = 0;
    var majorCount = 0;
    var moderateCount = 0;
    var minorCount = 0;

    for (finding in docFindings.toArray().vals()) {
      switch (finding.severity) {
        case (#critical) { criticalCount += 1 };
        case (#major) { majorCount += 1 };
        case (#moderate) { moderateCount += 1 };
        case (#minor) { minorCount += 1 };
      };
      if (finding.status == #open or finding.status == #inReview) {
        gaps.add({
          requirement = finding.findingType;
          missingIn = targetDoc.filename;
          severity = finding.severity;
        });
      } else {
        violations.add({
          rule = finding.findingType;
          violation = finding.description;
          location = targetDoc.filename;
          severity = finding.severity;
        });
      };
    };

    // Add cross-reference gaps from regulatory findings
    for (finding in regFindings.toArray().vals()) {
      if (finding.status == #open) {
        gaps.add({
          requirement = finding.findingType;
          missingIn = "Cross-reference: " # targetDoc.filename;
          severity = finding.severity;
        });
      };
    };

    // Calculate compliance score
    let totalIssues = criticalCount + majorCount + moderateCount + minorCount;
    let complianceScore = if (totalIssues == 0) { 100.0 }
      else {
        let penalty = criticalCount.toFloat() * 15.0 +
                      majorCount.toFloat() * 10.0 +
                      moderateCount.toFloat() * 5.0 +
                      minorCount.toFloat() * 2.0;
        let score = 100.0 - penalty;
        if (score < 0.0) { 0.0 } else { score };
      };

    // Determine risk level
    let riskLevel = if (criticalCount > 0) { #critical }
      else if (majorCount > 1) { #high }
      else if (majorCount > 0 or moderateCount > 2) { #medium }
      else { #low };

    // Generate suggested corrections
    let suggestedCorrections = List.empty<Text>();
    for (finding in docFindings.toArray().vals()) {
      if (finding.status == #open or finding.status == #inReview) {
        suggestedCorrections.add("Resolve: " # finding.findingType # " - " # finding.description);
      };
    };
    if (suggestedCorrections.size() == 0) {
      suggestedCorrections.add("No open findings. Maintain current compliance posture.");
    };

    let checkId = nextCheckId.value;
    nextCheckId.value += 1;

    #ok {
      checkId = checkId;
      documentId = documentId;
      complianceScore = complianceScore;
      gaps = gaps.toArray();
      violations = violations.toArray();
      riskLevel = riskLevel;
      suggestedCorrections = suggestedCorrections.toArray();
      generatedAt = now;
    }
  };

  public func runLessonsLearnedAnalysis(
    incidents : Map.Map<Common.IncidentId, IncidentRecord>,
    findings : Map.Map<Common.ComplianceCheckId, ComplianceFinding>,
    entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
    nextAnalysisId : { var value : Nat },
  ) : LessonsLearnedResult {
    let now = Int.abs(Time.now());
    let analysisId = nextAnalysisId.value;
    nextAnalysisId.value += 1;

    // Detect patterns from incident types
    let patternMap = Map.empty<Text, { count : Nat; equipment : List.List<Text>; desc : Text }>();
    for ((_id, inc) in incidents.entries()) {
      let key = inc.incidentType;
      switch (patternMap.get(key)) {
        case (?existing) {
          let newCount = existing.count + 1;
          let newEquip = existing.equipment;
          switch (inc.equipmentId) {
            case (?eq) {
              var alreadyIn = false;
              for (e in newEquip.toArray().vals()) {
                if (e == eq) { alreadyIn := true };
              };
              if (not alreadyIn) { newEquip.add(eq) };
            };
            case null {};
          };
          patternMap.add(key, { count = newCount; equipment = newEquip; desc = existing.desc });
        };
        case null {
          let equipList = List.empty<Text>();
          switch (inc.equipmentId) {
            case (?eq) { equipList.add(eq) };
            case null {};
          };
          patternMap.add(key, { count = 1; equipment = equipList; desc = inc.description });
        };
      };
    };

    let patterns = List.empty<Types.PatternDetection>();
    for ((pName, pdata) in patternMap.entries()) {
      if (pdata.count >= 1) {
        patterns.add({
          patternName = pName;
          occurrenceCount = pdata.count;
          affectedEquipment = pdata.equipment.toArray();
          description = pdata.desc;
        });
      };
    };

    // Identify high-risk conditions from critical/major incidents and open findings
    let highRiskConditions = List.empty<Types.RiskCondition>();
    let riskIncidentIds = List.empty<Common.IncidentId>();
    for ((_id, inc) in incidents.entries()) {
      switch (inc.severity) {
        case (#critical) { riskIncidentIds.add(inc.id) };
        case (#major) { riskIncidentIds.add(inc.id) };
        case (_) {};
      };
    };

    // Group by equipment for risk conditions
    let equipRiskMap = Map.empty<Text, { count : Nat; severity : Types.Severity; types : List.List<Text> }>();
    for ((_id, inc) in incidents.entries()) {
      switch (inc.equipmentId) {
        case (?eq) {
          switch (equipRiskMap.get(eq)) {
            case (?existing) {
              let newCount = existing.count + 1;
              let newTypes = existing.types;
              var alreadyIn = false;
              for (t in newTypes.toArray().vals()) {
                if (t == inc.incidentType) { alreadyIn := true };
              };
              if (not alreadyIn) { newTypes.add(inc.incidentType) };
              let worseSeverity = switch (inc.severity) {
                case (#critical) { #critical };
                case (#major) { if (existing.severity == #critical) { #critical } else { #major } };
                case (_) { existing.severity };
              };
              equipRiskMap.add(eq, { count = newCount; severity = worseSeverity; types = newTypes });
            };
            case null {
              let typeList = List.empty<Text>();
              typeList.add(inc.incidentType);
              equipRiskMap.add(eq, { count = 1; severity = inc.severity; types = typeList });
            };
          };
        };
        case null {};
      };
    };

    for ((eq, risk) in equipRiskMap.entries()) {
      let riskLevel = switch (risk.severity) {
        case (#critical) { #critical };
        case (#major) { #high };
        case (#moderate) { #medium };
        case (#minor) { #low };
      };
      let histIds = List.empty<Common.IncidentId>();
      for ((_id, inc) in incidents.entries()) {
        switch (inc.equipmentId) {
          case (?incEq) { if (incEq == eq) { histIds.add(inc.id) } };
          case null {};
        };
      };
      highRiskConditions.add({
        condition = "Equipment " # eq # " has " # Nat.toText(risk.count) # " incidents including " # (if (risk.types.size() > 0) { risk.types.toArray()[0] } else { "multiple issues" });
        riskLevel = riskLevel;
        historicalIncidents = histIds.toArray();
        recommendation = "Conduct detailed inspection and preventive maintenance on " # eq # ". Review incident history for recurring failure modes.";
      });
    };

    // Generate preventive actions
    let preventiveActions = List.empty<Types.PreventiveAction>();
    for (cond in highRiskConditions.toArray().vals()) {
      let priority = switch (cond.riskLevel) {
        case (#critical) { #urgent };
        case (#high) { #high };
        case (#medium) { #medium };
        case (#low) { #low };
      };
      preventiveActions.add({
        action = cond.recommendation;
        priority = priority;
        estimatedImpact = "Reduce " # (switch (cond.riskLevel) { case (#critical) { "critical" }; case (#high) { "high" }; case (#medium) { "medium" }; case (#low) { "low" } }) # " risk incidents by 60-80%";
      });
    };

    // Add general preventive actions from open findings
    for ((_id, finding) in findings.entries()) {
      if (finding.status == #open) {
        preventiveActions.add({
          action = "Address compliance finding: " # finding.findingType;
          priority = switch (finding.severity) {
            case (#critical) { #urgent };
            case (#major) { #high };
            case (#moderate) { #medium };
            case (#minor) { #low };
          };
          estimatedImpact = "Improve compliance posture and reduce regulatory risk";
        });
      };
    };

    {
      analysisId = analysisId;
      patterns = patterns.toArray();
      highRiskConditions = highRiskConditions.toArray();
      preventiveActions = preventiveActions.toArray();
      generatedAt = now;
    }
  };

  public func recordIncident(
    incidents : Map.Map<Common.IncidentId, IncidentRecord>,
    id : Common.IncidentId,
    title : Text,
    description : Text,
    equipmentId : ?Text,
    incidentType : Text,
    severity : Types.Severity,
    date : Text,
    sourceDocumentId : ?Common.DocumentId,
  ) : Result<IncidentRecord> {
    let record : IncidentRecord = {
      id = id;
      title = title;
      description = description;
      equipmentId = equipmentId;
      incidentType = incidentType;
      severity = severity;
      date = date;
      sourceDocumentId = sourceDocumentId;
      createdAt = Int.abs(Time.now());
    };
    incidents.add(id, record);
    #ok record;
  };

  public func recordComplianceFinding(
    findings : Map.Map<Common.ComplianceCheckId, ComplianceFinding>,
    id : Common.ComplianceCheckId,
    documentId : Common.DocumentId,
    findingType : Text,
    description : Text,
    severity : Types.Severity,
    status : Types.FindingStatus,
  ) : Result<ComplianceFinding> {
    let record : ComplianceFinding = {
      id = id;
      documentId = documentId;
      findingType = findingType;
      description = description;
      severity = severity;
      status = status;
      createdAt = Int.abs(Time.now());
    };
    findings.add(id, record);
    #ok record;
  };
};
