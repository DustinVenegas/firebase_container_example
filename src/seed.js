const db = require('./firebase');
const { v4: uuidv4 } = require('uuid');

async function seed() {
  console.log('starting seed...');

  const inventoryRef = db.collection('inventory');
  const userRef = db.collection('user');

  const sampleInventory = [
    { item_name: 'Lemonaide Classic', total: 100 },
    { item_name: 'Lemonaide Strawberry', total: 50 }
  ];

  const sampleUsers = [
    { name: 'Alice' },
    { name: 'Bob' }
  ];

  for (const item of sampleInventory) {
    const id = uuidv4();
    await inventoryRef.doc(id).set({ instrument_id: id, item_name: item.item_name, total: item.total });
    console.log('created inventory', id, item.item_name);
  }

  for (const u of sampleUsers) {
    const id = uuidv4();
    await userRef.doc(id).set({ user_id: id, name: u.name });
    console.log('created user', id, u.name);
  }

  console.log('seed complete');
  process.exit(0);
}

seed().catch(err => { console.error(err); process.exit(1); });
