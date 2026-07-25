ItemEvents.rightClicked('simplemagnet:simple_magnet', event => {
    const { item, player } = event;
    if (player.isCrouching()) {
        let isActive = item.has('minecraft:enchantment_glint_override');
        if (isActive) {
            item.remove('minecraft:enchantment_glint_override');
            player.setStatusMessage('§7Magnet: OFF');
        } else {
            item.set('minecraft:enchantment_glint_override', true);
            player.setStatusMessage('§aMagnet: ON');
        }
        player.swing();
        event.success(); 
    }
});

PlayerEvents.tick(event => {
    const { player, level, server } = event;

    if (level.time % 2 !== 0) return;

    let hasMagnet = (player.mainHandItem.id === 'simplemagnet:simple_magnet' && player.mainHandItem.has('minecraft:enchantment_glint_override')) ||
                    (player.offHandItem.id === 'simplemagnet:simple_magnet' && player.offHandItem.has('minecraft:enchantment_glint_override'));

    if (!hasMagnet && level.time % 20 === 0) {
        player.data.hasActiveMagnet = player.inventory.allItems.some(stack => 
            stack.id === 'simplemagnet:simple_magnet' && stack.has('minecraft:enchantment_glint_override')
        );
    } else if (hasMagnet) {
        player.data.hasActiveMagnet = true;
    }

    if (!player.data.hasActiveMagnet) return;

    let items = level.getEntities().filter(e => 
        e.type === 'minecraft:item' && 
        e.distanceToEntity(player) < 10
    );

    items.forEach(item => {
        let dx = player.x - item.x;
        let dy = (player.y + 0.5) - item.y;
        let dz = player.z - item.z;
        let dist = Math.sqrt(dx * dx + dy * dy + dz * dz);

        if (dist > 0.5) {
            item.setMotion(dx * 0.2, dy * 0.2, dz * 0.2);
            
            if (dist < 1.5) {
                item.mergeNbt({PickupDelay: 0});
            }
        }
    });
});