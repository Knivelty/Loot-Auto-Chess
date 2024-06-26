import { ClientComponents } from "./createClientComponents";
import { IWorld } from "./generated/typescript/contracts.gen";
import { Account, RpcProvider } from "starknet";
import { updateComponent } from "@dojoengine/recs";
import { zeroEntity } from "../utils";
import { opBuyHero } from "./opRender/opBuyHero";
import { opSellHero } from "./opRender/opSellHero";
import { opCommitPrepare } from "./opRender/opCommitPrepare";
import { logCall, logDebug } from "../ui/lib/utils";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { client }: { client: IWorld },
    clientComponents: ClientComponents,
    { GameStatus }: ClientComponents,
    rpcProvider: RpcProvider
) {
    const spawn = async (account: Account) => {
        try {
            const { transaction_hash: txHash } = await client.home.spawn({
                account,
            });

            // const result =
            // await client.provider.provider.waitForTransaction(txHash);
        } catch (e) {
            console.error(e);
        }
    };

    const startBattle = async (account: Account) => {
        try {
            return await client.home.startBattle({ account });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const commitPreparation = async (account: Account) => {
        await opCommitPrepare(
            { client },
            clientComponents,
            rpcProvider,
            account
        );
    };

    const nextRound = async (account: Account, choice: number) => {
        try {
            logDebug(`call next round, ${choice}`);
            return await client.home.nextRound({ account, choice });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const refreshAltar = async (account: Account) => {
        try {
            return await client.home.refreshAltar({ account });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const getCoin = async (account: Account) => {
        try {
            return await client.home.getCoin({ account });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const exit = async (account: Account) => {
        try {
            return await client.home.exit({ account });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const buyHero = async (
        account: Account,
        altarSlot: number,
        invSlot: number
    ) => {
        logCall(`buy hero: `, altarSlot, invSlot);
        await opBuyHero(
            { client },
            clientComponents,
            rpcProvider,
            account,
            altarSlot,
            invSlot
        );
    };

    const buyExp = async (account: Account) => {
        try {
            return await client.home.buyExp({
                account,
            });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const sellHero = async (account: Account, gid: number) => {
        try {
            await opSellHero(
                { client },
                clientComponents,
                rpcProvider,
                account,
                gid
            );
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const mergeHero = async (
        account: Account,
        gid1: number,
        gid2: number,
        gid3: number,
        invSlot: number
    ) => {
        try {
            logCall(`merge hero: `, gid1, gid2, gid3, invSlot);

            await client.home.mergeHero({ account, gid1, gid2, gid3, invSlot });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const playAnimation = async () => {
        updateComponent(GameStatus, zeroEntity, {
            shouldPlay: false,
        });
        updateComponent(GameStatus, zeroEntity, {
            shouldPlay: true,
        });
    };

    return {
        spawn,
        startBattle,
        playAnimation,
        nextRound,
        refreshAltar,
        getCoin,
        buyHero,
        buyExp,
        sellHero,
        mergeHero,
        commitPreparation,
        exit,
    };
}
