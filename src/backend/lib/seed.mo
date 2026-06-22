import Map "mo:core/Map";
import List "mo:core/List";
import Principal "mo:core/Principal";
import Time "mo:core/Time";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Array "mo:core/Array";
import Storage "mo:caffeineai-object-storage/Storage";
import Common "../types/common";
import DocumentTypes "../types/documents";
import KnowledgeTypes "../types/knowledge";
import ChatTypes "../types/chat";
import AnalysisTypes "../types/analysis";
import DashboardTypes "../types/dashboard";
import DocumentLib "../lib/documents";
import KnowledgeLib "../lib/knowledge";
import ChatLib "../lib/chat";
import AnalysisLib "../lib/analysis";
import DashboardLib "../lib/dashboard";

module {
  public type SeedState = {
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>;
    chunks : Map.Map<Common.ChunkId, DocumentTypes.DocumentChunk>;
    entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>;
    relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>;
    threads : Map.Map<Common.ChatThreadId, ChatTypes.ChatThread>;
    messages : Map.Map<Common.ChatMessageId, ChatTypes.ChatMessage>;
    incidents : Map.Map<Common.IncidentId, AnalysisTypes.IncidentRecord>;
    findings : Map.Map<Common.ComplianceCheckId, AnalysisTypes.ComplianceFinding>;
    activityLog : Map.Map<Nat, DashboardTypes.ActivityItem>;
    nextDocumentId : { var value : Nat };
    nextChunkId : { var value : Nat };
    nextEntityId : { var value : Nat };
    nextRelationshipId : { var value : Nat };
    nextThreadId : { var value : Nat };
    nextMessageId : { var value : Nat };
    nextIncidentId : { var value : Nat };
    nextCheckId : { var value : Nat };
    nextAnalysisId : { var value : Nat };
    nextActivityId : { var value : Nat };
  };

  public func seedAll(state : SeedState) : () {
    let systemPrincipal = Principal.fromText("aaaaa-aa");
    let now = Int.abs(Time.now());

    // ========== DOCUMENTS ==========
    let doc1 = seedDocument(state, systemPrincipal, "MR-2024-001_P-101_Maintenance.pdf", "application/pdf", 245000, #extracted, ?"Maintenance Report - Pump P-101\n\nDate: 2024-01-15\nTechnician: John Smith\nWork Type: Preventive Maintenance\n\nFindings: Bearing wear detected on drive end. Vibration levels elevated to 8.2 mm/s. Oil analysis showed metal particles.\n\nActions Taken: Replaced bearings, realigned coupling, changed lubricant.\n\nNext Service: 2024-04-15");
    let doc2 = seedDocument(state, systemPrincipal, "IR-2024-003_B-12_Inspection.pdf", "application/pdf", 189000, #extracted, ?"Inspection Report - Boiler B-12\n\nDate: 2024-02-20\nInspector: Sarah Chen\n\nFindings: Tube fouling observed in Section 3. Wall thickness measurements show 12% reduction. Safety valve tested OK.\n\nRecommendations: Schedule chemical cleaning. Monitor wall thickness quarterly.");
    let doc3 = seedDocument(state, systemPrincipal, "SOP-P-102-Startup.pdf", "application/pdf", 56000, #extracted, ?"Standard Operating Procedure - Pump P-102 Startup\n\n1. Verify suction valve open\n2. Check seal pot level > 50%\n3. Engage jacking gear\n4. Start motor - monitor current < 45A\n5. Open discharge valve gradually\n6. Verify flow > 120 m3/hr\n\nSafety: Wear PPE. Emergency stop button location: Panel A3");
    let doc4 = seedDocument(state, systemPrincipal, "INC-2024-007_M-201_Failure.pdf", "application/pdf", 312000, #extracted, ?"Incident Report - Motor M-201 Failure\n\nDate: 2024-03-10\nTime: 14:32\nEquipment: Motor M-201 (450kW induction motor)\n\nEvent: Motor tripped on overload. Inspection revealed burnt winding in Phase C.\n\nRoot Cause: Insulation degradation due to moisture ingress from failed gland seal.\n\nCorrective Action: Rewound stator, replaced gland seal, installed heater. Downtime: 72 hours.");
    let doc5 = seedDocument(state, systemPrincipal, "MR-2024-002_V-301_Repair.pdf", "application/pdf", 178000, #extracted, ?"Maintenance Record - Valve V-301\n\nDate: 2024-01-28\nTechnician: Mike Rodriguez\n\nIssue: Control valve hunting, process oscillating +/- 5%.\n\nDiagnosis: Positioner air leak. Actuator diaphragm cracked.\n\nRepair: Replaced positioner and diaphragm. Calibrated stroke 0-100%. Tested OK.");
    let doc6 = seedDocument(state, systemPrincipal, "Safety-Proc-Confined-Space.pdf", "application/pdf", 89000, #extracted, ?"Safety Procedure - Confined Space Entry\n\n1. Obtain permit from area supervisor\n2. Test atmosphere - O2 > 19.5%, LEL < 10%\n3. Ventilate continuously\n4. Attendant stationed outside\n5. Rescue equipment pre-positioned\n6. Communication check every 15 min\n\nReference: OSHA 29 CFR 1910.146");
    let doc7 = seedDocument(state, systemPrincipal, "Reg-Factory-Act-2023.pdf", "application/pdf", 456000, #extracted, ?"Factory Act 2023 - Compliance Requirements\n\nSection 12: All pressure vessels must be inspected annually by certified inspector.\nSection 15: Emergency shutdown systems must be tested monthly.\nSection 22: Maintenance records must be retained for 5 years.\nSection 28: Incident reporting within 24 hours to regulatory authority.");
    let doc8 = seedDocument(state, systemPrincipal, "WO-2024-045_C-401_Overhaul.pdf", "application/pdf", 267000, #extracted, ?"Work Order - Compressor C-401 Major Overhaul\n\nDate: 2024-04-01\nAssigned: Overhaul Team B\n\nScope: Complete disassembly, inspection, reassembly of centrifugal compressor.\n\nFindings: Impeller erosion on 2nd stage. Seal clearance 0.25mm (spec 0.15mm).\n\nActions: Replaced impeller, re-machined seal housing, rebalanced rotor.\n\nCompletion: 2024-04-08. Performance test: 102% of design capacity.");
    let doc9 = seedDocument(state, systemPrincipal, "MR-2024-005_P-102_Seal.pdf", "application/pdf", 134000, #extracted, ?"Maintenance Report - Pump P-102 Mechanical Seal\n\nDate: 2024-03-22\nTechnician: Lisa Park\n\nIssue: Seal leakage observed - 2 drops/minute from seal chamber.\n\nDiagnosis: Seal face cracked due to dry running after suction blockage.\n\nAction: Replaced mechanical seal with dual seal arrangement. Installed low-flow alarm.");
    let doc10 = seedDocument(state, systemPrincipal, "INC-2024-009_B-13_Trip.pdf", "application/pdf", 198000, #extracted, ?"Incident Report - Boiler B-13 Safety Trip\n\nDate: 2024-04-12\nTime: 03:15\n\nEvent: Boiler tripped on high drum level. Investigation found level transmitter drift.\n\nRoot Cause: Transmitter calibration shifted due to ambient temperature cycling.\n\nCorrective: Replaced with compensated transmitter. Added redundant level switch.");

    // ========== INCIDENTS ==========
    let inc1 = seedIncident(state, "Bearing Failure - Pump P-101", "Drive end bearing catastrophic failure during normal operation. Vibration alarm preceded failure by 48 hours.", ?"P-101", "Mechanical Failure", #critical, "2024-01-10", ?doc1.id);
    let inc2 = seedIncident(state, "Tube Leak - Boiler B-12", "Water wall tube leak in Section 3. Unit derated to 70% capacity.", ?"B-12", "Corrosion", #major, "2024-02-18", ?doc2.id);
    let inc3 = seedIncident(state, "Motor Burnout - M-201", "450kW motor winding failure. Phase C insulation breakdown.", ?"M-201", "Electrical Failure", #critical, "2024-03-10", ?doc4.id);
    let inc4 = seedIncident(state, "Valve Malfunction - V-301", "Control valve hunting causing process instability. Production loss 4 hours.", ?"V-301", "Instrumentation", #moderate, "2024-01-28", ?doc5.id);
    let inc5 = seedIncident(state, "Compressor Surge - C-401", "Anti-surge valve delayed opening caused brief surge event. No mechanical damage.", ?"C-401", "Process Upset", #minor, "2024-03-05", null);
    let inc6 = seedIncident(state, "Boiler Trip - B-13", "Safety trip on high drum level during night shift. Automatic actions functioned correctly.", ?"B-13", "Instrumentation", #moderate, "2024-04-12", ?doc10.id);

    // ========== COMPLIANCE FINDINGS ==========
    let find1 = seedFinding(state, doc7.id, "Missing Annual Inspection", "Boiler B-12 annual inspection overdue by 3 months per Factory Act Section 12.", #critical, #open);
    let find2 = seedFinding(state, doc6.id, "Emergency Stop Not Tested", "Emergency stop system on Pump P-101 not tested in last 45 days. Exceeds monthly requirement.", #major, #inReview);
    let find3 = seedFinding(state, doc7.id, "Incomplete Maintenance Records", "Motor M-201 maintenance records missing post-overhaul test data. Section 22 violation.", #moderate, #open);
    let find4 = seedFinding(state, doc7.id, "Late Incident Report", "Compressor C-401 incident reported 72 hours after occurrence. Exceeds 24-hour requirement.", #major, #resolved);
    let find5 = seedFinding(state, doc6.id, "Missing PPE Documentation", "Confined space entry log missing PPE verification signatures for 2 entries.", #minor, #open);
    let find6 = seedFinding(state, doc7.id, "Uninspected Pressure Vessel", "Vessel V-302 not included in annual inspection schedule.", #critical, #inReview);
    let find7 = seedFinding(state, doc7.id, "Outdated Safety Procedure", "Lock-out/Tag-out procedure revision 3.2 still in use. Current is 4.1.", #moderate, #open);
    let find8 = seedFinding(state, doc6.id, "Training Certificate Expired", "3 technicians with expired confined space rescue certification.", #major, #inReview);

    // ========== ENTITIES ==========
    let e1 = seedEntity(state, "Pump P-101", #equipment, [("type", "Centrifugal Pump"), ("location", "Unit 1 - Floor A"), ("status", "Operational"), ("capacity", "150 m3/hr"), ("manufacturer", "Grundfos")], ?doc1.id);
    let e2 = seedEntity(state, "Pump P-102", #equipment, [("type", "Centrifugal Pump"), ("location", "Unit 1 - Floor B"), ("status", "Operational"), ("capacity", "200 m3/hr"), ("manufacturer", "KSB")], ?doc3.id);
    let e3 = seedEntity(state, "Boiler B-12", #equipment, [("type", "Water Tube Boiler"), ("location", "Power House"), ("status", "Operational"), ("capacity", "120 t/hr steam"), ("pressure", "65 bar")], ?doc2.id);
    let e4 = seedEntity(state, "Boiler B-13", #equipment, [("type", "Water Tube Boiler"), ("location", "Power House"), ("status", "Operational"), ("capacity", "120 t/hr steam"), ("pressure", "65 bar")], ?doc10.id);
    let e5 = seedEntity(state, "Motor M-201", #equipment, [("type", "Induction Motor"), ("location", "Unit 2 - Mezzanine"), ("status", "Operational"), ("power", "450 kW"), ("voltage", "6.6 kV")], ?doc4.id);
    let e6 = seedEntity(state, "Motor M-202", #equipment, [("type", "Induction Motor"), ("location", "Unit 2 - Ground"), ("status", "Standby"), ("power", "450 kW"), ("voltage", "6.6 kV")], null);
    let e7 = seedEntity(state, "Valve V-301", #equipment, [("type", "Control Valve"), ("location", "Unit 1 - Pipe Rack"), ("status", "Operational"), ("size", "DN150"), ("actuator", "Pneumatic")], ?doc5.id);
    let e8 = seedEntity(state, "Valve V-302", #equipment, [("type", "Isolation Valve"), ("location", "Unit 1 - Pipe Rack"), ("status", "Operational"), ("size", "DN200"), ("actuator", "Manual")], null);
    let e9 = seedEntity(state, "Compressor C-401", #equipment, [("type", "Centrifugal Compressor"), ("location", "Unit 3 - Compressor House"), ("status", "Operational"), ("capacity", "5000 Nm3/hr"), ("discharge_pressure", "45 bar")], ?doc8.id);
    let e10 = seedEntity(state, "Bearing Wear", #failure, [("category", "Mechanical"), ("frequency", "High"), ("typical_cause", "Lubrication degradation")], ?doc1.id);
    let e11 = seedEntity(state, "Tube Fouling", #failure, [("category", "Thermal"), ("frequency", "Medium"), ("typical_cause", "Water quality")], ?doc2.id);
    let e12 = seedEntity(state, "Motor Winding Failure", #failure, [("category", "Electrical"), ("frequency", "Low"), ("typical_cause", "Moisture ingress")], ?doc4.id);
    let e13 = seedEntity(state, "Seal Leakage", #failure, [("category", "Mechanical"), ("frequency", "High"), ("typical_cause", "Dry running")], ?doc9.id);
    let e14 = seedEntity(state, "John Smith", #person, [("role", "Maintenance Technician"), ("department", "Mechanical"), ("certification", "Vibration Analysis Level 2")], ?doc1.id);
    let e15 = seedEntity(state, "Sarah Chen", #person, [("role", "Inspector"), ("department", "Quality Assurance"), ("certification", "API 510 Certified")], ?doc2.id);
    let e16 = seedEntity(state, "Mike Rodriguez", #person, [("role", "Maintenance Technician"), ("department", "Instrumentation"), ("certification", "Control Valve Specialist")], ?doc5.id);
    let e17 = seedEntity(state, "Lisa Park", #person, [("role", "Maintenance Technician"), ("department", "Mechanical"), ("certification", "Mechanical Seal Specialist")], ?doc9.id);
    let e18 = seedEntity(state, "Factory Act 2023", #regulation, [("authority", "Department of Industrial Safety"), ("effective_date", "2023-01-01"), ("scope", "All manufacturing facilities")], ?doc7.id);
    let e19 = seedEntity(state, "OSHA 29 CFR 1910.146", #regulation, [("authority", "OSHA"), ("topic", "Confined Space Entry"), ("scope", "All industrial facilities")], ?doc6.id);
    let e20 = seedEntity(state, "Unit 1", #location, [("type", "Process Unit"), ("supervisor", "Robert Jones"), ("equipment_count", "45")], null);

    // ========== RELATIONSHIPS ==========
    seedRel(state, e10.id, e1.id, #causes, 0.92, ?doc1.id); // Bearing Wear causes P-101
    seedRel(state, e1.id, e14.id, #maintainedBy, 0.95, ?doc1.id); // P-101 maintainedBy John Smith
    seedRel(state, e11.id, e3.id, #causes, 0.88, ?doc2.id); // Tube Fouling causes B-12
    seedRel(state, e3.id, e15.id, #inspectedBy, 0.95, ?doc2.id); // B-12 inspectedBy Sarah Chen
    seedRel(state, e12.id, e5.id, #causes, 0.94, ?doc4.id); // Motor Winding Failure causes M-201
    seedRel(state, e13.id, e2.id, #causes, 0.89, ?doc9.id); // Seal Leakage causes P-102
    seedRel(state, e2.id, e17.id, #maintainedBy, 0.95, ?doc9.id); // P-102 maintainedBy Lisa Park
    seedRel(state, e7.id, e16.id, #maintainedBy, 0.95, ?doc5.id); // V-301 maintainedBy Mike Rodriguez
    seedRel(state, e1.id, e20.id, #locatedAt, 0.98, null); // P-101 locatedAt Unit 1
    seedRel(state, e2.id, e20.id, #locatedAt, 0.98, null); // P-102 locatedAt Unit 1
    seedRel(state, e7.id, e20.id, #locatedAt, 0.98, null); // V-301 locatedAt Unit 1
    seedRel(state, e8.id, e20.id, #locatedAt, 0.98, null); // V-302 locatedAt Unit 1
    seedRel(state, e1.id, e10.id, #partOf, 0.90, ?doc1.id); // P-101 partOf Bearing Wear
    seedRel(state, e3.id, e11.id, #partOf, 0.90, ?doc2.id); // B-12 partOf Tube Fouling
    seedRel(state, e5.id, e12.id, #partOf, 0.90, ?doc4.id); // M-201 partOf Motor Winding Failure
    seedRel(state, e2.id, e13.id, #partOf, 0.90, ?doc9.id); // P-102 partOf Seal Leakage
    seedRel(state, e1.id, e2.id, #similarTo, 0.85, null); // P-101 similarTo P-102
    seedRel(state, e3.id, e4.id, #similarTo, 0.90, null); // B-12 similarTo B-13
    seedRel(state, e5.id, e6.id, #similarTo, 0.95, null); // M-201 similarTo M-202
    seedRel(state, e18.id, e3.id, #compliesWith, 0.80, ?doc7.id); // Factory Act compliesWith B-12
    seedRel(state, e18.id, e4.id, #compliesWith, 0.80, ?doc7.id); // Factory Act compliesWith B-13
    seedRel(state, e19.id, e1.id, #compliesWith, 0.85, ?doc6.id); // OSHA compliesWith P-101
    seedRel(state, e10.id, e12.id, #leadsTo, 0.75, null); // Bearing Wear leadsTo Motor Winding Failure
    seedRel(state, e11.id, e13.id, #leadsTo, 0.70, null); // Tube Fouling leadsTo Seal Leakage
    seedRel(state, e1.id, doc1.id, #references, 0.99, ?doc1.id); // P-101 references doc1
    seedRel(state, e3.id, doc2.id, #references, 0.99, ?doc2.id); // B-12 references doc2
    seedRel(state, e5.id, doc4.id, #references, 0.99, ?doc4.id); // M-201 references doc4
    seedRel(state, e7.id, doc5.id, #references, 0.99, ?doc5.id); // V-301 references doc5
    seedRel(state, e9.id, doc8.id, #references, 0.99, ?doc8.id); // C-401 references doc8

    // ========== CHAT THREADS ==========
    let t1 = seedThread(state, systemPrincipal, "Pump P-101 Maintenance History");
    seedMessage(state, t1.id, #user, "What maintenance history does Pump P-101 have?", [], null);
    seedMessage(state, t1.id, #assistant, "Pump P-101 has the following maintenance history:\n\n1. **Jan 15, 2024** - Preventive maintenance by John Smith. Bearing wear detected and replaced. Vibration levels were elevated to 8.2 mm/s.\n\n2. **Key Finding**: Oil analysis showed metal particles indicating early bearing degradation.\n\n3. **Status**: Operational after repair. Next service scheduled April 15, 2024.\n\n**Confidence**: 95%\n**Source**: MR-2024-001_P-101_Maintenance.pdf", [{ documentId = doc1.id; documentName = "MR-2024-001_P-101_Maintenance.pdf"; chunkIndex = 0; excerpt = "Bearing wear detected on drive end. Vibration levels elevated to 8.2 mm/s." }], ?0.95);

    let t2 = seedThread(state, systemPrincipal, "Boiler B-12 Inspection Results");
    seedMessage(state, t2.id, #user, "What were the inspection findings for Boiler B-12?", [], null);
    seedMessage(state, t2.id, #assistant, "Boiler B-12 inspection (Feb 20, 2024) by Sarah Chen found:\n\n- **Tube fouling** in Section 3 affecting heat transfer efficiency\n- **Wall thickness reduction** of 12% in affected tubes\n- **Safety valve** tested and functioning correctly\n\n**Recommendations**:\n1. Schedule chemical cleaning within 30 days\n2. Monitor wall thickness quarterly\n3. Consider tube replacement if degradation exceeds 15%\n\n**Confidence**: 92%\n**Source**: IR-2024-003_B-12_Inspection.pdf", [{ documentId = doc2.id; documentName = "IR-2024-003_B-12_Inspection.pdf"; chunkIndex = 0; excerpt = "Tube fouling observed in Section 3. Wall thickness measurements show 12% reduction." }], ?0.92);

    let t3 = seedThread(state, systemPrincipal, "Motor M-201 Failure Analysis");
    seedMessage(state, t3.id, #user, "Why did Motor M-201 fail?", [], null);
    seedMessage(state, t3.id, #assistant, "Motor M-201 failure analysis:\n\n**Root Cause**: Insulation degradation in Phase C winding due to moisture ingress from a failed gland seal.\n\n**Failure Sequence**:\n1. Gland seal failed, allowing moisture into motor housing\n2. Moisture degraded winding insulation over time\n3. Phase C insulation breakdown caused overload trip\n\n**Corrective Actions**:\n- Stator rewound with Class F insulation\n- Gland seal replaced with improved design\n- Space heater installed to prevent condensation\n\n**Downtime**: 72 hours\n**Confidence**: 94%\n**Source**: INC-2024-007_M-201_Failure.pdf", [{ documentId = doc4.id; documentName = "INC-2024-007_M-201_Failure.pdf"; chunkIndex = 0; excerpt = "Insulation degradation due to moisture ingress from failed gland seal." }], ?0.94);

    let t4 = seedThread(state, systemPrincipal, "Compliance Status Overview");
    seedMessage(state, t4.id, #user, "What are our current compliance gaps?", [], null);
    seedMessage(state, t4.id, #assistant, "Current compliance status summary:\n\n**Critical Findings (2)**:\n1. Boiler B-12 annual inspection overdue by 3 months\n2. Pressure vessel V-302 not in inspection schedule\n\n**Major Findings (3)**:\n1. Emergency stop on P-101 not tested in 45 days\n2. Motor M-201 records missing post-overhaul data\n3. 3 technicians with expired confined space certifications\n\n**Overall Compliance Score**: 68%\n**Risk Level**: HIGH\n\n**Recommended Actions**:\n- Schedule B-12 inspection immediately\n- Add V-302 to annual inspection program\n- Update all maintenance records\n- Renew expired certifications\n\n**Source**: Factory Act 2023, Safety Procedures", [{ documentId = doc7.id; documentName = "Reg-Factory-Act-2023.pdf"; chunkIndex = 0; excerpt = "All pressure vessels must be inspected annually by certified inspector." }], ?0.88);

    // ========== ACTIVITY LOG ==========
    seedActivity(state, #documentUploaded, "Uploaded maintenance report for Pump P-101", ?doc1.id);
    seedActivity(state, #documentProcessed, "Extracted text from B-12 inspection report", ?doc2.id);
    seedActivity(state, #entityExtracted, "Identified 20 entities from document processing", null);
    seedActivity(state, #relationshipCreated, "Created 25 knowledge graph relationships", null);
    seedActivity(state, #chatCreated, "New chat: Pump P-101 Maintenance History", null);
    seedActivity(state, #analysisRun, "Root cause analysis completed for Motor M-201", null);
    seedActivity(state, #complianceChecked, "Compliance check: 8 findings identified", null);
    seedActivity(state, #incidentRecorded, "Incident recorded: Bearing Failure - Pump P-101", ?doc1.id);
    seedActivity(state, #documentUploaded, "Uploaded work order for Compressor C-401 overhaul", ?doc8.id);
    seedActivity(state, #documentProcessed, "Extracted text from C-401 work order", ?doc8.id);
    seedActivity(state, #incidentRecorded, "Incident recorded: Boiler B-13 safety trip", ?doc10.id);
  };

  // ========== HELPER FUNCTIONS ==========

  func seedDocument(
    state : SeedState,
    owner : Principal,
    filename : Text,
    mimeType : Text,
    fileSize : Nat,
    status : DocumentTypes.DocumentStatus,
    extractedText : ?Text,
  ) : DocumentTypes.Document {
    let id = state.nextDocumentId.value;
    state.nextDocumentId.value += 1;
    let now = Int.abs(Time.now());
    let doc : DocumentTypes.Document = {
      id;
      owner;
      filename;
      mimeType;
      blob = Blob.fromArray([]);
      status;
      extractedText;
      metadata = {
        fileSize;
        pageCount = null;
        equipmentIds = [];
        assetNames = [];
        maintenanceEvents = [];
        failureTypes = [];
        dates = [];
        personnel = [];
        safetyReferences = [];
        regulatoryReferences = [];
      };
      createdAt = now;
      updatedAt = now;
    };
    state.documents.add(id, doc);
    doc;
  };

  func seedIncident(
    state : SeedState,
    title : Text,
    description : Text,
    equipmentId : ?Text,
    incidentType : Text,
    severity : AnalysisTypes.Severity,
    date : Text,
    sourceDocumentId : ?Common.DocumentId,
  ) : AnalysisTypes.IncidentRecord {
    let id = state.nextIncidentId.value;
    state.nextIncidentId.value += 1;
    let record : AnalysisTypes.IncidentRecord = {
      id;
      title;
      description;
      equipmentId;
      incidentType;
      severity;
      date;
      sourceDocumentId;
      createdAt = Int.abs(Time.now());
    };
    state.incidents.add(id, record);
    record;
  };

  func seedFinding(
    state : SeedState,
    documentId : Common.DocumentId,
    findingType : Text,
    description : Text,
    severity : AnalysisTypes.Severity,
    status : AnalysisTypes.FindingStatus,
  ) : AnalysisTypes.ComplianceFinding {
    let id = state.nextCheckId.value;
    state.nextCheckId.value += 1;
    let finding : AnalysisTypes.ComplianceFinding = {
      id;
      documentId;
      findingType;
      description;
      severity;
      status;
      createdAt = Int.abs(Time.now());
    };
    state.findings.add(id, finding);
    finding;
  };

  func seedEntity(
    state : SeedState,
    name : Text,
    entityType : KnowledgeTypes.EntityType,
    properties : [(Text, Text)],
    sourceDocumentId : ?Common.DocumentId,
  ) : KnowledgeTypes.Entity {
    let id = state.nextEntityId.value;
    state.nextEntityId.value += 1;
    let entity : KnowledgeTypes.Entity = {
      id;
      name;
      entityType;
      properties;
      sourceDocumentId;
      createdAt = Int.abs(Time.now());
    };
    state.entities.add(id, entity);
    entity;
  };

  func seedRel(
    state : SeedState,
    sourceId : Common.EntityId,
    targetId : Common.EntityId,
    relationshipType : KnowledgeTypes.RelationshipType,
    confidence : Float,
    sourceDocumentId : ?Common.DocumentId,
  ) : () {
    let id = state.nextRelationshipId.value;
    state.nextRelationshipId.value += 1;
    let rel : KnowledgeTypes.Relationship = {
      id;
      sourceId;
      targetId;
      relationshipType;
      confidence;
      sourceDocumentId;
      createdAt = Int.abs(Time.now());
    };
    state.relationships.add(id, rel);
  };

  func seedThread(
    state : SeedState,
    owner : Principal,
    title : Text,
  ) : ChatTypes.ChatThread {
    let id = state.nextThreadId.value;
    state.nextThreadId.value += 1;
    let now = Int.abs(Time.now());
    let thread : ChatTypes.ChatThread = {
      id;
      owner;
      title;
      createdAt = now;
      updatedAt = now;
    };
    state.threads.add(id, thread);
    thread;
  };

  func seedMessage(
    state : SeedState,
    threadId : Common.ChatThreadId,
    role : ChatTypes.MessageRole,
    content : Text,
    sources : [ChatTypes.SourceCitation],
    confidence : ?Float,
  ) : () {
    let id = state.nextMessageId.value;
    state.nextMessageId.value += 1;
    let message : ChatTypes.ChatMessage = {
      id;
      threadId;
      role;
      content;
      sources;
      confidence;
      createdAt = Int.abs(Time.now());
    };
    state.messages.add(id, message);
  };

  func seedActivity(
    state : SeedState,
    activityType : DashboardTypes.ActivityType,
    description : Text,
    relatedDocumentId : ?Common.DocumentId,
  ) : () {
    let id = state.nextActivityId.value;
    state.nextActivityId.value += 1;
    let item : DashboardTypes.ActivityItem = {
      id;
      activityType;
      description;
      timestamp = Int.abs(Time.now());
      relatedDocumentId;
    };
    state.activityLog.add(id, item);
  };
}
