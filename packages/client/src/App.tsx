import { useEffect } from "react";
import { useNetworkLayer } from "./ui/hooks/useNetworkLayer";
import { PhaserLayer } from "./phaser/phaserLayer";
import { store } from "./store";
import { UI } from "./ui";

function App() {
    const networkLayer = useNetworkLayer();

    useEffect(() => {
        if (!networkLayer || !networkLayer.account) return;

        console.log("Setting network layer");

        store.setState({ networkLayer });
    }, [networkLayer]);

    return (
        <div>
            <div className="w-full h-screen  bg-[url('assets/bg.png')] bg-no-repeat bg-cover bg-center	 text-white flex justify-center fixed">
                <div className="self-center">
                    {!networkLayer && "loading..."}
                </div>
            </div>
            <PhaserLayer networkLayer={networkLayer} />
            <UI />
        </div>
    );
}

export default App;
