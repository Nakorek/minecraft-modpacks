ClientEvents.loggedIn(event => {
    Client.runCommand('flywheel backend flywheel:off')
})
