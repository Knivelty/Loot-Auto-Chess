// Generated by dojo-bindgen on Mon, 8 Apr 2024 13:47:52 +0000. Do not modify this file manually.
import { Account, CallData } from "starknet";
import { DojoProvider } from "@dojoengine/core";
import * as models from "./models.gen";
import { PieceChange, RoundResult } from "../../types";

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export async function setupWorld(provider: DojoProvider) {
    // System definitions for `autochessia::home::home` contract
    function home() {
        const contract_name = "home";

        // Call the `dojo_resource` system with the specified Account and calldata
        const dojoResource = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "dojo_resource",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `initialize` system with the specified Account and calldata
        const initialize = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "initialize",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `setCreatureProfile` system with the specified Account and calldata
        const setCreatureProfile = async (props: {
            account: Account;
            p: models.CreatureProfile;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "setCreatureProfile",
                    [
                        props.p.creature_index,
                        props.p.level,
                        props.p.rarity,
                        props.p.health,
                        props.p.attack,
                        props.p.armor,
                        props.p.range,
                        props.p.speed,
                        props.p.initiative,
                    ]
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `setStageProfile` system with the specified Account and calldata
        const setStageProfile = async (props: {
            account: Account;
            p: models.StageProfile;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "setStageProfile",
                    [props.p.stage, props.p.pieceCount]
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `spawn` system with the specified Account and calldata
        const spawn = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "spawn",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `refreshAltar` system with the specified Account and calldata
        const refreshAltar = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "refreshAltar",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `buyHero` system with the specified Account and calldata
        const buyHero = async (props: {
            account: Account;
            altarSlot: number;
            invSlot: number;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "buyHero",
                    [props.altarSlot, props.invSlot]
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `buyExp` system with the specified Account and calldata
        const buyExp = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "buyExp",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `sellHero` system with the specified Account and calldata
        const sellHero = async (props: { account: Account; gid: number }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "sellHero",
                    [props.gid]
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `commitPreparation` system with the specified Account and calldata
        const commitPreparation = async (props: {
            account: Account;
            changes: PieceChange[];
            result: RoundResult;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "commitPreparation",
                    CallData.compile({
                        changes: props.changes,
                        result: props.result,
                    })
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `nextRound` system with the specified Account and calldata
        const nextRound = async (props: {
            account: Account;
            choice: models.CurseOptionType;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "nextRound",
                    [props.choice]
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `startBattle` system with the specified Account and calldata
        const startBattle = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "startBattle",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `mergeHero` system with the specified Account and calldata
        const mergeHero = async (props: {
            account: Account;
            gid1: number;
            gid2: number;
            gid3: number;
            invSlot: number;
        }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "mergeHero",
                    [props.gid1, props.gid2, props.gid3, props.invSlot]
                );
            } catch (error) {
                console.error("Error executing mergeHero:", error);
                throw error;
            }
        };

        // Call the `getCoin` system with the specified Account and calldata
        const getCoin = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "getCoin",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        // Call the `exit` system with the specified Account and calldata
        const exit = async (props: { account: Account }) => {
            try {
                return await provider.execute(
                    props.account,
                    contract_name,
                    "exit",
                    []
                );
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        return {
            dojoResource,
            initialize,
            setCreatureProfile,
            setStageProfile,
            spawn,
            refreshAltar,
            buyHero,
            buyExp,
            sellHero,
            commitPreparation,
            nextRound,
            startBattle,
            getCoin,
            exit,
            mergeHero,
        };
    }

    return {
        home: home(),
    };
}
