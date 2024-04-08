import { ClientComponents } from "./createClientComponents";
import { IWorld } from "./generated/typescript/contracts.gen";
import { Account } from "starknet";
import {
    getComponentValue,
    getComponentValueStrict,
    updateComponent,
} from "@dojoengine/recs";
import { zeroEntity } from "../utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { isBoolean, isEqual, isNull, isUndefined } from "lodash";
import { PieceChange } from "./types";
import { processBattle } from "../phaser/systems/utils/processBattleLogs";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { client }: { client: IWorld },
    clientComponents: ClientComponents,
    { GameStatus, LocalPiecesChangeTrack, Piece, LocalPiece }: ClientComponents
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
        try {
            // calculate the diff

            const playerEntity = getEntityIdFromKeys([BigInt(account.address)]);

            const piecesTrack = getComponentValue(
                LocalPiecesChangeTrack,
                playerEntity
            );

            console.log("piecesTrack: ", piecesTrack);

            const changes: PieceChange[] = piecesTrack?.gids
                .map((gid) => {
                    const entity = getEntityIdFromKeys([BigInt(gid)]);
                    const local = getComponentValueStrict(LocalPiece, entity);
                    const remote = getComponentValueStrict(Piece, entity);

                    if (isEqual(local, remote)) {
                        return undefined;
                    } else {
                        return {
                            gid: gid,
                            idx: local.idx,
                            slot: local.slot,
                            x: local.x,
                            y: local.y,
                        };
                    }
                })
                .filter(Boolean) as PieceChange[];

            const { processBattleLogs } = processBattle(clientComponents);

            const { result } = processBattleLogs();

            console.log("commit changes: ", changes);

            return await client.home.commitPreparation({
                account,
                changes,
                result: {
                    win: result.win,
                    healthDecrease: result.healthDecrease,
                },
            });
        } catch (e) {
            console.error(e);
            throw e;
        }
    };

    const nextRound = async (account: Account) => {
        try {
            return await client.home.nextRound({ account });
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

    const buyHero = async (
        account: Account,
        altarSlot: number,
        invSlot: number
    ) => {
        try {
            return await client.home.buyHero({
                account,
                altarSlot,
                invSlot,
            });
        } catch (e) {
            console.error(e);
            throw e;
        }
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
            return await client.home.sellHero({ account, gid });
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
        commitPreparation,
    };
}
