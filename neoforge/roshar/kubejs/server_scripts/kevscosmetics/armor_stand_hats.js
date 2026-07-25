// Adds hats to armor stands from Kevs Cosmetics
const ALLOWED_STAND_HATS = [
  'kevdelights:chefs_hat',
  'kevscosmetics:hard_hat'
]

ItemEvents.entityInteracted(event => {
  const { target, item, player } = event
  
  if (target.type.toString() !== 'minecraft:armor_stand') return
  
  if (!ALLOWED_STAND_HATS.includes(item.id)) return
  
  const currentHeadItem = target.headArmorItem
  if (!currentHeadItem.isEmpty()) {
    player.give(currentHeadItem) 
  }
  
  target.headArmorItem = item.copy().withCount(1)
  
  item.count--
  
  player.playSound('minecraft:item.armor.equip_leather')
  
  event.cancel()
})