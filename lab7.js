// Task1

db.post_documents.insertOne({
  postCode: "POST-9001",
  visibility: "public",
  createdAt: ISODate("2024-07-19T14:00:00Z"),
  author: {
    email: "olga@example.com",
    fullName: "Ольга Соколова"
  },
  group: {
    groupCode: "GR-01",
    title: "Путешествия",
    category: "Хобби"
  },
  tags: ["лето", "море"],
  comments: [
    {
      authorEmail: "ivan@example.com",
      text: "Отличный пост",
      createdAt: ISODate("2024-07-19T15:00:00Z")
    }
  ]
});


// Task2
db.post_documents.updateOne(
  { postCode: "POST-1001" },
  {
    $push: {
      comments: {
        authorEmail: "maria@example.com",
        text: "Интересно!",
        createdAt: ISODate("2024-07-20T09:00:00Z")
      }
    }
  }
);


// Task3
db.post_documents.find(
  { visibility: "public" },
  { _id: 0, postCode: 1, visibility: 1, createdAt: 1, "group.title": 1 }
);


// Task4
db.post_documents.find(
  { "author.email": "olga@example.com" },
  { _id: 0, postCode: 1, "author.fullName": 1, visibility: 1 }
);


// Task5
db.post_documents.find(
  { tags: "лето" },
  { _id: 0, postCode: 1, tags: 1, visibility: 1 }
);


// Task6
db.post_documents.updateOne(
  { postCode: "POST-1002" },
  { $set: { visibility: "private", "group.category": "Архив" } }
);


// Task7
db.post_documents.aggregate([
  { $match: { visibility: { $in: ["public", "private"] } } },
  {
    $group: {
      _id: "$group.title",
      postsCount: { $sum: 1 },
      lastPostDate: { $max: "$createdAt" }
    }
  }
]);


// Task8
db.createView(
  "popular_tags_view",
  "post_documents",
  [
    { $unwind: "$tags" },
    { $group: { _id: "$tags", postsCount: { $sum: 1 } } },
    { $project: { _id: 0, tag: "$_id", postsCount: 1 } }
  ]
);