ClientEvents.tick(event => {
    const { player, level } = event
    if (!player) return

    // TIMING - Run once every second

    if (level.time % 20 !== 0) return 

    if (player.mainHandItem.id !== 'minecraft:light') return

    const radius = 5 
    const pX = player.blockX
    const pY = player.blockY
    const pZ = player.blockZ

    for (let x = -radius; x <= radius; x++) {
        for (let y = -radius; y <= radius; y++) {
            for (let z = -radius; z <= radius; z++) {
                
                let block = level.getBlock(pX + x, pY + y, pZ + z)

                if (block.id === 'minecraft:light') {
                    level.addParticle(
                        'minecraft:end_rod', 
                        block.x + 0.5, block.y + 0.2, block.z + 0.5, 
                        0, 0.06, 0 
                    )

                    let randomOffset = (Math.random() - 0.5) * 0.2
                    level.addParticle(
                        'minecraft:end_rod', 
                        block.x + 0.5 + randomOffset, block.y + 0.1, block.z + 0.5 + randomOffset, 
                        0, 0.03, 0 
                    )

                    level.addParticle(
                        'minecraft:end_rod', 
                        block.x + 0.5, block.y + 0.6, block.z + 0.5, 
                        0, 0.01, 0 
                    )
                }
            }
        }
    }
})