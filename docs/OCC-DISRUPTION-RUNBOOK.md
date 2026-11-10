# Aviation Operations Control Centre (OCC) Disruption Runbook

**Classification**: Flight Operations Platform Engineering & Architecture Runbook  
**Authority**: Grounded on Microsoft Frontier Tour 2026–2027 Keynote Architecture  
**Author**: Shahrad Alerasoul  

---

## 1. Operational Scenario: Mechanical Grounding at Stand 512

### Incident Profile
* **Flight**: BA-942 (London Heathrow EGLL -> Munich EDDM)
* **Equipment**: Airbus A321 Neo (Tail `G-TTNA`)
* **Passenger Load**: 182 passengers (including 48 transatlantic connections transferring at Munich)
* **Defect**: Hydraulic actuator fault detected during pushback pre-flight checks
* **Mechanical Hold**: Stand 512, estimated quarantine duration: 90 minutes minimum

### SLA & Regulatory Pressure Clock
1. **Eurocontrol NMOC Corridor Slot**: Departure slot expires in **22 minutes**. If missed, flight corridor across the Alps is cancelled, cascading into an estimated 4-hour delay.
2. **Statutory UK/EU261 Liability**: If arrival delay exceeds 180 minutes across 182 passengers, statutory compensation is **£520 per passenger**:
   $$\text{Total Immediate Exposure} = 182 \times £520 = £94,640$$
3. **CAA Flight Time Limitations (FTL)**: Operating crew duty period expires at 14:15 UTC. With departure delayed beyond 12:30 UTC, the crew legally runs out of hours mid-flight, grounding the aircraft without certified crew.

---

## 2. Multi-IQ Sensing & Tail-Swap Resolution

```
+----------------------------------------------------------------------------------------------------+
|                                       MICROSOFT TEAMS INGRESS                                      |
|                                       Channel: #occ-hub-disruption                                 |
|  Dispatcher: "BA-942 Stand 512 actuator leak. Maintenance calling 90m quarantine."                |
+--------------------------------------------------+-------------------------------------------------+
                                                   |
                                                   v
+----------------------------------------------------------------------------------------------------+
|                                4-PILLAR MICROSOFT IQ CONTEXT MESH                                  |
|                                                                                                    |
|  [Work IQ]    Graph v2.x extracts affected flight (BA-942), tail (G-TTNA), 182 pax, 48 connects.   |
|  [Web IQ]     Queries Eurocontrol NMOC for slot window; pulls METAR convective storm radar.        |
|  [Foundry IQ] Evaluates CAA FTL duty limits & £94,640 EU261 compensation thresholds.               |
|  [Fabric IQ]  Queries OneLake Direct Lake semantic measure [Fleet_Standby_Availability].          |
|               Identifies standby A321 Neo (G-NEOU) at Stand 514 with 240 engine hours buffer.     |
+--------------------------------------------------+-------------------------------------------------+
                                                   |
                                                   v
+----------------------------------------------------------------------------------------------------+
|                                    SOVEREIGN HUMAN DECISION GATE                                   |
|                        Interactive Teams Adaptive Card: HOLD FOR SIGN-OFF                          |
|                                                                                                    |
|  Tail Proposed: G-NEOU (Stand 514) | Crew Legal Buffer: 1h 45m | Liability Averted: £94,640        |
|  Action: [APPROVE TAIL-SWAP] (Requires Chief Duty Pilot Entra ID MFA)                              |
+----------------------------------------------------------------------------------------------------+
```

---

## 3. Sovereign Gate Protocol

Under airline safety compliance, autonomous agents are strictly forbidden from writing unvetted mutations into flight reservation mainframes (Sabre / Amadeus Altea).

1. **State Lock**: Agent stages proposed swap in Azure Cosmos DB (`case_records`) under state `HOLD_FOR_SIGN_OFF`.
2. **Action Trigger**: The Chief Duty Pilot inspects the pre-calculated FTL safety figures and passenger connection breakdown on Teams.
3. **MFA Verification**: Approving the adaptive card submits an Entra ID authenticated action.
4. **Execution Dispatch**: Only after pilot sign-off does the ground crew push tail `G-NEOU` to flight BA-942.

