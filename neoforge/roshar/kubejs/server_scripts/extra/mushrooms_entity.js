// Handle right-clicking entities with mushrooms to shrink/grow, or stew to reset
ItemEvents.entityInteracted(event => {
  const { player, item, hand, target, server } = event;

  if (item.id !== 'minecraft:brown_mushroom' && item.id !== 'minecraft:red_mushroom' && item.id !== 'minecraft:mushroom_stew') {
    return;
  }

  // Blacklist for specific boss mobs
  const blacklist = [
    'minecraft:ender_dragon', 
    'minecraft:wither', 
    'minecraft:warden'
  ];
  
  if (blacklist.includes(target.type)) {
    return;
  }

  const scaleAttr = target.getAttribute('minecraft:generic.scale');
  if (!scaleAttr) return; 

  let currentScale = scaleAttr.getBaseValue();

  if (item.id === 'minecraft:mushroom_stew') {
    if (currentScale !== 1.0) {
      scaleAttr.setBaseValue(1.0);
      
      if (server) {
        server.runCommandSilent(`execute at ${target.uuid} run playsound minecraft:entity.experience_orb.pickup player @a ~ ~ ~ 1.0 1.0`);
      }
      
      player.swing(hand);
      
      if (!player.isCreative()) {
        item.count--;
        player.give('minecraft:bowl');
      }
      
      player.displayClientMessage(Text.of("Target size restored to normal").color('gray'), true);
      event.cancel();
    }
    return;
  }

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

    if (server) {
      let eatPitch = Math.random() * 0.2 + 0.9;
      server.runCommandSilent(`execute at ${target.uuid} run playsound minecraft:entity.generic.eat player @a ~ ~ ~ 1.0 ${eatPitch}`);
      server.runCommandSilent(`execute at ${target.uuid} run playsound ${scaleSound} player @a ~ ~ ~ 1.0 ${soundPitch}`);
    }

    player.swing(hand);

    if (!player.isCreative()) {
      item.count--;
    }

    player.displayClientMessage(Text.of(`Target size adjusted to ${newScale}`).color(textColor), true);

    event.cancel();
  }
});