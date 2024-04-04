import { Button } from "antd";
import { UIStore, useUIStore } from "../../store";
import { useDojo } from "../hooks/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { useHotkeys } from "react-hotkeys-hook";

export function ShopButton() {
    const {
        account: { playerEntity },
        clientComponents: { Player },
    } = useDojo();
    const setShowShop = useUIStore((state: UIStore) => state.setShopShow);
    const shopShow = useUIStore((state: UIStore) => {
        return state.shopShow;
    });

    useHotkeys("p", () => {
        setShowShop(!shopShow);
    });

    const player = useComponentValue(Player, playerEntity);

    return (
        <div className="absolute right-[10%] bottom-[10%]">
            <Button
                className="w-32 h-32 bg-white border-black  text-black  rounded-full
                hover:bg-gray-300 transition duration-300 text-lg"
                onClick={async () => {
                    setShowShop(!shopShow);
                }}
            >
                $ {player?.coin}
            </Button>
        </div>
    );
}
