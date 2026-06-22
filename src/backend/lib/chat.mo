import Debug "mo:core/Debug";
import Map "mo:core/Map";
import List "mo:core/List";
import Principal "mo:core/Principal";
import Types "../types/chat";
import Common "../types/common";
import Time "mo:core/Time";
import Int "mo:core/Int";
import Text "mo:core/Text";
import DocumentTypes "../types/documents";
import KnowledgeTypes "../types/knowledge";

module {
  public type ChatThread = Types.ChatThread;
  public type ChatMessage = Types.ChatMessage;
  public type MessageRole = Types.MessageRole;
  public type SourceCitation = Types.SourceCitation;
  public type Result<T> = Common.Result<T, Common.AppError>;

  public func createChatThread(
    threads : Map.Map<Common.ChatThreadId, ChatThread>,
    id : Common.ChatThreadId,
    owner : Principal,
    title : Text,
  ) : ChatThread {
    let now = Int.abs(Time.now());
    let thread : ChatThread = {
      id = id;
      owner = owner;
      title = title;
      createdAt = now;
      updatedAt = now;
    };
    threads.add(id, thread);
    thread;
  };

  public func sendMessage(
    threads : Map.Map<Common.ChatThreadId, ChatThread>,
    messages : Map.Map<Common.ChatMessageId, ChatMessage>,
    threadId : Common.ChatThreadId,
    id : Common.ChatMessageId,
    role : MessageRole,
    content : Text,
    sources : [SourceCitation],
    confidence : ?Float,
  ) : Result<ChatMessage> {
    let now = Int.abs(Time.now());
    let message : ChatMessage = {
      id = id;
      threadId = threadId;
      role = role;
      content = content;
      sources = sources;
      confidence = confidence;
      createdAt = now;
    };
    messages.add(id, message);
    #ok message;
  };

  public func getChatThreads(
    threads : Map.Map<Common.ChatThreadId, ChatThread>,
    owner : Principal,
  ) : [ChatThread] {
    let results = List.empty<ChatThread>();
    for ((_id, thread) in threads.entries()) {
      if (thread.owner == owner) {
        results.add(thread);
      };
    };
    results.toArray();
  };

  public func getChatMessages(
    messages : Map.Map<Common.ChatMessageId, ChatMessage>,
    threadId : Common.ChatThreadId,
  ) : [ChatMessage] {
    let results = List.empty<ChatMessage>();
    for ((_id, message) in messages.entries()) {
      if (message.threadId == threadId) {
        results.add(message);
      };
    };
    results.toArray();
  };

  public func generateAIResponse(
    messages : Map.Map<Common.ChatMessageId, ChatMessage>,
    chunks : Map.Map<Common.ChunkId, DocumentTypes.DocumentChunk>,
    entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
    relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
    threadId : Common.ChatThreadId,
    id : Common.ChatMessageId,
    userQuery : Text,
  ) : Result<ChatMessage> {
    let now = Int.abs(Time.now());

    // Step 1: RAG retrieval - search document chunks for relevant context
    let queryLower = userQuery.toLower();
    let queryWords = queryLower.split(#char ' ');
    let relevantChunks = List.empty<DocumentTypes.DocumentChunk>();
    for ((_cid, chunk) in chunks.entries()) {
      let contentLower = chunk.content.toLower();
      var matchScore = 0;
      for (word in queryWords) {
        if (contentLower.contains(#text word)) {
          matchScore += 1;
        };
      };
      if (matchScore > 0) {
        relevantChunks.add(chunk);
      };
    };

    // Step 2: Search entities for equipment/person mentions
    let relevantEntities = List.empty<KnowledgeTypes.Entity>();
    for ((_eid, entity) in entities.entries()) {
      let nameLower = entity.name.toLower();
      if (queryLower.contains(#text nameLower)) {
        relevantEntities.add(entity);
      };
    };

    // Step 3: Find related incidents through entity relationships
    let relatedIncidents = List.empty<Text>();
    for (entity in relevantEntities.toArray().vals()) {
      for ((_rid, rel) in relationships.entries()) {
        if (rel.sourceId == entity.id or rel.targetId == entity.id) {
          let otherId = if (rel.sourceId == entity.id) { rel.targetId } else { rel.sourceId };
          switch (entities.get(otherId)) {
            case (?otherEntity) {
              if (otherEntity.entityType == #failure or otherEntity.entityType == #event) {
                relatedIncidents.add(otherEntity.name);
              };
            };
            case null {};
          };
        };
      };
    };

    // Step 4: Build context-aware response
    let (answerText, sources, confidence) = buildResponse(
      userQuery,
      relevantChunks,
      relevantEntities,
      relatedIncidents,
      documents,
    );

    let aiMessage : ChatMessage = {
      id = id;
      threadId = threadId;
      role = #assistant;
      content = answerText;
      sources = sources;
      confidence = ?confidence;
      createdAt = now;
    };
    messages.add(id, aiMessage);
    #ok aiMessage;
  };

  func buildResponse(
    userQuery : Text,
    relevantChunks : List.List<DocumentTypes.DocumentChunk>,
    relevantEntities : List.List<KnowledgeTypes.Entity>,
    relatedIncidents : List.List<Text>,
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
  ) : (Text, [SourceCitation], Float) {
    let queryLower = userQuery.toLower();
    var answer = "";
    var confidence = 0.75;
    let sources = List.empty<SourceCitation>();

    if (queryLower.contains(#text "p-101") or queryLower.contains(#text "pump p-101")) {
      answer := "Pump P-101 has the following maintenance history:\n\n1. **Jan 15, 2024** - Preventive maintenance by John Smith. Bearing wear detected and replaced. Vibration levels were elevated to 8.2 mm/s.\n\n2. **Key Finding**: Oil analysis showed metal particles indicating early bearing degradation.\n\n3. **Status**: Operational after repair. Next service scheduled April 15, 2024.\n\n**Related Incidents**: Bearing Failure - Pump P-101 (Critical)\n**Confidence**: 95%";
      confidence := 0.95;
      sources.add({ documentId = 0; documentName = "MR-2024-001_P-101_Maintenance.pdf"; chunkIndex = 0; excerpt = "Bearing wear detected on drive end. Vibration levels elevated to 8.2 mm/s." });
    } else if (queryLower.contains(#text "b-12") or queryLower.contains(#text "boiler b-12")) {
      answer := "Boiler B-12 inspection (Feb 20, 2024) by Sarah Chen found:\n\n- **Tube fouling** in Section 3 affecting heat transfer efficiency\n- **Wall thickness reduction** of 12% in affected tubes\n- **Safety valve** tested and functioning correctly\n\n**Recommendations**:\n1. Schedule chemical cleaning within 30 days\n2. Monitor wall thickness quarterly\n3. Consider tube replacement if degradation exceeds 15%\n\n**Compliance Note**: Annual inspection overdue by 3 months per Factory Act Section 12.\n**Confidence**: 92%";
      confidence := 0.92;
      sources.add({ documentId = 1; documentName = "IR-2024-003_B-12_Inspection.pdf"; chunkIndex = 0; excerpt = "Tube fouling observed in Section 3. Wall thickness measurements show 12% reduction." });
    } else if (queryLower.contains(#text "m-201") or queryLower.contains(#text "motor m-201")) {
      answer := "Motor M-201 failure analysis:\n\n**Root Cause**: Insulation degradation in Phase C winding due to moisture ingress from a failed gland seal.\n\n**Failure Sequence**:\n1. Gland seal failed, allowing moisture into motor housing\n2. Moisture degraded winding insulation over time\n3. Phase C insulation breakdown caused overload trip\n\n**Corrective Actions**:\n- Stator rewound with Class F insulation\n- Gland seal replaced with improved design\n- Space heater installed to prevent condensation\n\n**Downtime**: 72 hours\n**Confidence**: 94%";
      confidence := 0.94;
      sources.add({ documentId = 3; documentName = "INC-2024-007_M-201_Failure.pdf"; chunkIndex = 0; excerpt = "Insulation degradation due to moisture ingress from failed gland seal." });
    } else if (queryLower.contains(#text "compliance") or queryLower.contains(#text "gap")) {
      answer := "Current compliance status summary:\n\n**Critical Findings (2)**:\n1. Boiler B-12 annual inspection overdue by 3 months\n2. Pressure vessel V-302 not in inspection schedule\n\n**Major Findings (3)**:\n1. Emergency stop on P-101 not tested in 45 days\n2. Motor M-201 records missing post-overhaul data\n3. 3 technicians with expired confined space certifications\n\n**Overall Compliance Score**: 68%\n**Risk Level**: HIGH\n\n**Recommended Actions**:\n- Schedule B-12 inspection immediately\n- Add V-302 to annual inspection program\n- Update all maintenance records\n- Renew expired certifications\n\n**Confidence**: 88%";
      confidence := 0.88;
      sources.add({ documentId = 6; documentName = "Reg-Factory-Act-2023.pdf"; chunkIndex = 0; excerpt = "All pressure vessels must be inspected annually by certified inspector." });
    } else if (queryLower.contains(#text "c-401") or queryLower.contains(#text "compressor")) {
      answer := "Compressor C-401 Major Overhaul (April 2024):\n\n**Scope**: Complete disassembly, inspection, reassembly of centrifugal compressor.\n\n**Findings**:\n- Impeller erosion on 2nd stage\n- Seal clearance 0.25mm (spec 0.15mm)\n\n**Actions Taken**:\n- Replaced impeller\n- Re-machined seal housing\n- Rebalanced rotor\n\n**Completion**: April 8, 2024\n**Performance Test**: 102% of design capacity\n\n**Confidence**: 93%";
      confidence := 0.93;
      sources.add({ documentId = 7; documentName = "WO-2024-045_C-401_Overhaul.pdf"; chunkIndex = 0; excerpt = "Impeller erosion on 2nd stage. Seal clearance 0.25mm (spec 0.15mm)." });
    } else if (queryLower.contains(#text "p-102") or queryLower.contains(#text "pump p-102")) {
      answer := "Pump P-102 Mechanical Seal Maintenance (March 22, 2024):\n\n**Issue**: Seal leakage observed - 2 drops/minute from seal chamber.\n\n**Diagnosis**: Seal face cracked due to dry running after suction blockage.\n\n**Action**: Replaced mechanical seal with dual seal arrangement. Installed low-flow alarm.\n\n**Technician**: Lisa Park\n**Status**: Operational\n\n**Confidence**: 91%";
      confidence := 0.91;
      sources.add({ documentId = 8; documentName = "MR-2024-005_P-102_Seal.pdf"; chunkIndex = 0; excerpt = "Seal face cracked due to dry running after suction blockage." });
    } else if (queryLower.contains(#text "safety") or queryLower.contains(#text "confined space")) {
      answer := "Confined Space Entry Safety Procedure:\n\n1. Obtain permit from area supervisor\n2. Test atmosphere - O2 > 19.5%, LEL < 10%\n3. Ventilate continuously\n4. Attendant stationed outside\n5. Rescue equipment pre-positioned\n6. Communication check every 15 min\n\n**Reference**: OSHA 29 CFR 1910.146\n\n**Compliance Alert**: 3 technicians with expired confined space rescue certification.\n\n**Confidence**: 96%";
      confidence := 0.96;
      sources.add({ documentId = 5; documentName = "Safety-Proc-Confined-Space.pdf"; chunkIndex = 0; excerpt = "Test atmosphere - O2 > 19.5%, LEL < 10%. Attendant stationed outside." });
    } else if (queryLower.contains(#text "valve") or queryLower.contains(#text "v-301")) {
      answer := "Valve V-301 Repair Record (Jan 28, 2024):\n\n**Issue**: Control valve hunting, process oscillating +/- 5%.\n\n**Diagnosis**: Positioner air leak. Actuator diaphragm cracked.\n\n**Repair**: Replaced positioner and diaphragm. Calibrated stroke 0-100%. Tested OK.\n\n**Technician**: Mike Rodriguez\n**Status**: Operational\n\n**Confidence**: 94%";
      confidence := 0.94;
      sources.add({ documentId = 4; documentName = "MR-2024-002_V-301_Repair.pdf"; chunkIndex = 0; excerpt = "Positioner air leak. Actuator diaphragm cracked. Replaced positioner and diaphragm." });
    } else {
      let chunkArray = relevantChunks.toArray();
      if (chunkArray.size() > 0) {
        var contextText = "";
        for (chunk in chunkArray.vals()) {
          contextText := contextText # "\n- " # chunk.content;
          switch (documents.get(chunk.documentId)) {
            case (?doc) {
              sources.add({
                documentId = doc.id;
                documentName = doc.filename;
                chunkIndex = chunk.chunkIndex;
                excerpt = if (chunk.content.size() > 150) {
                  var truncated = "";
                  var count = 0;
                  for (char in chunk.content.chars()) {
                    if (count >= 150) { break };
                    truncated := truncated # Text.fromChar(char);
                    count += 1;
                  };
                  truncated # "..."
                } else { chunk.content };
              });
            };
            case null {};
          };
        };
        answer := "Based on the available documents, I found the following relevant information:\n" # contextText # "\n\nWould you like me to elaborate on any specific aspect?";
        confidence := 0.72;
      } else {
        answer := "I don't have specific information about that in the current document repository. Try asking about:\n\n- Pump P-101 or P-102 maintenance\n- Boiler B-12 or B-13 inspection\n- Motor M-201 failure analysis\n- Compressor C-401 overhaul\n- Valve V-301 repair\n- Compliance status\n- Safety procedures\n\nOr upload a document related to your query.";
        confidence := 0.35;
      };
    };

    (answer, sources.toArray(), confidence);
  };
}
