
# Azure Cost Optimization: Serverless Billing Records Archival Solution

## 📘 Problem Statement

We have a serverless architecture where billing records are stored in **Azure Cosmos DB**. With over 2 million records and each up to 300 KB in size, storage costs have significantly increased. Records older than **3 months** are rarely accessed but must remain available with a **response time in seconds**.

## 🧩 Constraints

- Read-heavy system
- No downtime
- No data loss
- No changes to existing API contracts

---

## ✅ Proposed Solution

### Tiered Storage Architecture (Hot + Cold)

| Component            | Purpose                                              |
|----------------------|------------------------------------------------------|
| Cosmos DB (Hot Tier) | Stores recent (≤ 3 months) billing records           |
| Azure Blob Storage   | Archives older (> 3 months) records in JSON format   |
| Azure Function       | Manages periodic data archival & on-demand retrieval|
| Durable Functions    | Ensures long-running tasks (migration, retrieval)   |
| Azure Table Storage *(optional)* | For metadata index of archived records |

### 🔁 Data Lifecycle

1. **New Data** → Stored in Cosmos DB
2. **Older Data** → Archived to Blob via Durable Function
3. **On Read Request**:
   - Try Cosmos DB
   - If not found, fetch from Blob
   - API contract remains unchanged

---

## 🧠 Benefits

- ⚡ Significant cost reduction using cold storage
- 🔒 Seamless transition with no data loss or downtime
- 🧩 Transparent to API users
- 🧰 Easy to maintain & scalable

---

## 🧰 Sample Pseudocode

### Archival Function

```python
for record in cosmos_query("SELECT * FROM c WHERE c.timestamp < three_months_ago"):
    write_to_blob(f"archive/{record.id}.json", record)
    delete_from_cosmos(record.id)
```

### Retrieval Function

```python
record = cosmos_db.find(id)
if not record:
    record = blob_storage.read(f"archive/{id}.json")
return record
```

---

## 🖼️ Architecture Diagram

![Architecture](A_flowchart-style_digital_illustration_depicts_a_s.png)

---

## 📝 Bonus: AI Assistance

This solution was co-developed using ChatGPT. Prompts and conversation history are included in `chat_history.md` for reference.

---

## 🚀 How to Use

1. Clone this repo
2. Set up Cosmos DB, Blob Storage, and Functions in Azure
3. Deploy functions with Timer and HTTP triggers
4. Monitor and tune retrieval latency

---

## 📂 Folder Structure

```
.
├── archive_function/        # Azure Function for archival
├── retrieve_function/       # Function to fetch from Blob if needed
├── chat_history.md          # Prompts used with ChatGPT
├── README.md                # Project explanation and architecture
└── A_flowchart-style_digital_illustration_depicts_a_s.png  # Diagram
```

---

## 🙏 Thanks

Submitted as part of the Symplique Solutions Azure Engineer Assessment.
