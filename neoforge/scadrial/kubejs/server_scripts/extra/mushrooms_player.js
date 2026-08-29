// Handle shift right-clicking raw mushrooms to shrink/grow
ItemEvents.rightClicked(event => {
  const { player, item, hand } = event;

  if (!player.isCrouching()) {
    return;
  }

  if (item.id !== 'minecraft:brown_mushroom' && item.id !== 'minecraft:red_mushroom') {
    return;
  }

  const scaleAttr = player.getAttribute('minecraft:generic.scale');
  if (!scaleAttr) return; 

  let currentScale = scaleAttr.getBaseValue();
  let newScale = currentScale;
  let textColor = '';
  let scaleSound = '';
  let soundPitch = 1.0;

  if (item.id === 'minecraft:brown_mushroom') {
    newScale = Math.max(0.25, currentScale - 0.25);
    textColor = '#8B4513'; 
    scaleSound = 'minecraft:entity.generic.eat';
    soundPitch = 1.5; 
  } else if (item.id === 'minecraft:red_mushroom') {
    newScale = Math.min(3.0, currentScale + 0.25);
    textColor = 'red'; 
    scaleSound = 'minecraft:entity.generic.eat';
    soundPitch = 0.5; 
  }

  if (currentScale !== newScale) {
    scaleAttr.setBaseValue(newScale);

    if (event.server) {
      let eatPitch = Math.random() * 0.2 + 0.9;
      event.server.runCommandSilent(`execute at ${player.uuid} run playsound minecraft:entity.generic.eat player @a ~ ~ ~ 1.0 ${eatPitch}`);
      event.server.runCommandSilent(`execute at ${player.uuid} run playsound ${scaleSound} player @a ~ ~ ~ 1.0 ${soundPitch}`);
    }

    player.swing(hand);

    if (!player.isCreative()) {
      item.count--;
    }

    player.displayClientMessage(Text.of(`Size adjusted to ${newScale}`).color(textColor), true);

    event.cancel();
  }
});

ItemEvents.foodEaten(event => {
  const { player, item } = event;

  if (item.id === 'minecraft:mushroom_stew') {
    const scaleAttr = player.getAttribute('minecraft:generic.scale');
    
    if (scaleAttr && scaleAttr.getBaseValue() !== 1.0) {
      scaleAttr.setBaseValue(1.0);
      
      if (event.server) {
        event.server.runCommandSilent(`execute at ${player.uuid} run playsound minecraft:entity.experience_orb.pickup player @a ~ ~ ~ 1.0 1.0`);
      }
      
      player.displayClientMessage(Text.of("Size restored to normal").color('gray'), true);
    }
  }
});

PlayerEvents.respawned(event => {
  const { player } = event;
  const scaleAttr = player.getAttribute('minecraft:generic.scale');
  
  if (scaleAttr) {
    scaleAttr.setBaseValue(1.0);
  }
});