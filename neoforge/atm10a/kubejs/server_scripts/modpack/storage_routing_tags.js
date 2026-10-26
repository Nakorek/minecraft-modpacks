// Item-type categories for ME Tag Storage Buses. Rebuilt on world load/reload.
// Classification uses each type's default stack, not the number being stored.
// Per-stack component overrides cannot be represented by an item tag.
ServerEvents.tags('item', event => {
  const nonStackable = []
  const stackable = []

  Item.getTypeList().forEach(id => {
    const stack = Item.of(id)
    if (stack.isEmpty()) return

    if (stack.getMaxStackSize() === 1) {
      nonStackable.push(id)
    } else {
      stackable.push(id)
    }
  })

  event.removeAll('modpack:non_stackable')
  event.removeAll('modpack:stackable')
  event.add('modpack:non_stackable', nonStackable)
  event.add('modpack:stackable', stackable)

  console.info('[storage-routing] Classified ' + nonStackable.length
    + ' non-stackable and ' + stackable.length + ' stackable item types')
})
