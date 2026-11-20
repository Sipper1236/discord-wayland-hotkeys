// User-owned Vesktop integration inspired by kalpanakonara/discord-wayland-hotkeys.
const { app, BrowserWindow } = require('electron');
const fs = require('fs');
const path = require('path');
const net = require('net');
const archive = '/opt/vesktop/resources/app.asar';
const pkg = require(archive + '/package.json');
app.setName('vesktop');
app.setVersion(pkg.version);
app.setPath('userData', path.join(app.getPath('appData'), 'vesktop'));
app.setAppPath(archive);
// Acquire ownership before loading Vesktop or touching its IPC socket.
if (!app.requestSingleInstanceLock()) {
    app.exit(0);
    return;
}
require(archive + '/' + pkg.main);
const socket = path.join(process.env.XDG_RUNTIME_DIR, 'vesktop-hotkeys.sock');
async function invoke(action) {
    const win = BrowserWindow.getAllWindows().find(w => !w.isDestroyed() && /^https:\/\/(?:canary\.|ptb\.)?discord\.com\//.test(w.webContents.getURL()));
    if (!win) throw Error('Discord window is not ready');
    return win.webContents.executeJavaScript(`(async () => {
        const w = window.Vencord?.Webpack;
        if (!w) throw Error('Vencord webpack API is not ready');
        const actions = w.findByProps('toggleSelfMute', 'toggleSelfDeaf');
        const store = w.findByProps('isSelfMute', 'isSelfDeaf');
        if (!actions || !store) throw Error('Discord voice modules are not ready');
        const state = () => ({mute: store.isSelfMute(), deafen: store.isSelfDeaf()});
        const before = state();
        if (${JSON.stringify(action)} === 'mute') actions.toggleSelfMute();
        if (${JSON.stringify(action)} === 'deafen') actions.toggleSelfDeaf();
        await new Promise(r => setTimeout(r, 150));
        return {before, after: state()};
    })()`);
}
app.whenReady().then(() => {
    // The instance lock guarantees that only this process owns the socket.
    try { fs.unlinkSync(socket); } catch (e) { if (e.code !== 'ENOENT') throw e; }
    let queue = Promise.resolve();
    const server = net.createServer({allowHalfOpen: true}, client => {
        client.setTimeout(3000, () => client.destroy());
        let data = '';
        client.on('data', chunk => {
            data += chunk;
            if (!data.includes('\n')) return;
            const action = data.trim();
            client.removeAllListeners('data');
            if (!['mute', 'deafen', 'status'].includes(action)) return client.end(JSON.stringify({error:'Unknown action'})+'\n');
            queue = queue.then(async () => {
                try { client.end(JSON.stringify(await invoke(action))+'\n'); }
                catch (e) { client.end(JSON.stringify({error:e.message})+'\n'); }
            });
        });
        client.on('error', () => {});
    });
    server.on('error', e => console.error('[VesktopHotkeys]', e));
    server.listen(socket, () => { fs.chmodSync(socket, 0o600); console.log('[VesktopHotkeys] Ready:', socket); });
    app.on('will-quit', () => { server.close(); try { fs.unlinkSync(socket); } catch {} });
});
