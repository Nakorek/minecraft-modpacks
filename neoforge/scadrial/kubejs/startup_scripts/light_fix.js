BlockEvents.modification(event => {
    event.modify('minecraft:light', block => {
        block.destroySpeed = 0.0 
        block.requiresTool = false
    })
})