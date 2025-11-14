// ============================================
// INSERT MONGODB - CIUDADES DE PERÚ
// ============================================
// INSTRUCCIONES:
// 1. Reemplaza "ID_PAIS_AQUI" con el ObjectId real del país Perú
// 2. Ejecuta este script en MongoDB Shell o MongoDB Compass
// 3. Los _id se generarán automáticamente
// ============================================

// Obtener el ObjectId del país Perú (ejecuta primero si no lo tienes):
// db.countries.findOne({ name: "Perú" }) o db.countries.findOne({ name: "Peru" })

const PERU_ID = ObjectId("507f1f77bcf86cd799439021"); // ObjectId de Perú

db.cities.insertMany([
  {
    name: "Lima",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Arequipa",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Trujillo",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Chiclayo",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Piura",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Iquitos",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Cusco",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Huancayo",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Tacna",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  },
  {
    name: "Ica",
    createdAt: new Date(),
    country: { $ref: "countries", $id: PERU_ID }
  }
]);

print("✅ Se insertaron 10 ciudades de Perú exitosamente.");

