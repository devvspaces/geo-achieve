import { Actor, HttpAgent } from '@dfinity/agent';
import { createActor, idlFactory } from '../../../declarations/backend';
import { createActor as createNftActor } from '../../../declarations/geonft';
import { AuthClient } from '@dfinity/auth-client';

export const BACKEND_CANISTER_ID = process.env.BACKEND_CANISTER_ID;
export const CANISTER_ID_GEONFT = process.env.CANISTER_ID_GEONFT;

export const IsDev = process.env.NODE_ENV !== 'production';

export function getHost() {
	return IsDev ? 'http://127.0.0.1:4943' : 'https://icp-api.io';
}

export async function createBackend() {
  if (!BACKEND_CANISTER_ID) {
    throw new Error('Backend canister ID is not defined.');
  }
	return createActor(BACKEND_CANISTER_ID, {
		agentOptions: {
			host: getHost()
		}
	});
}

export async function createGeoNft() {
  if (!CANISTER_ID_GEONFT) {
    throw new Error('GEO NFT canister ID is not defined.');
  }
	return createNftActor(CANISTER_ID_GEONFT, {
		agentOptions: {
			host: getHost()
		}
	});
}

export async function initializeBackend() {
	try {
		const agent = await HttpAgent.create({
			host: getHost()
		});

		// Fetch root key only in development or local environments
		if (IsDev) {
			await agent.fetchRootKey();
		}

		// Initialize the Actor for the backend canister
		// @ts-ignore
		const backend = Actor.createActor(idlFactory, {
			agent,
			canisterId: BACKEND_CANISTER_ID
		});

		console.log('Backend initialized successfully.');

		return backend;
	} catch (error) {
		console.error('Error initializing backend:', error);
	}
}


/**
 * Get the identity provider URL
 * @see https://github.com/dfinity/examples/blob/master/motoko/auth_client_demo/src/auth_client_demo_assets/react/use-auth-client.jsx
 */
export const getIdentityProvider = () => {
  if (process.env.DFX_NETWORK === "ic") {
    return "https://identity.ic0.app";
  }

  // Safari does not support localhost subdomains
  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  if (isSafari) {
    return `http://localhost:4943/?canisterId=${process.env.CANISTER_ID_INTERNET_IDENTITY}`;
  }

  return `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`;
};

/**
 * Create an auth client
 */
export async function createClient() {
  const authClient = await AuthClient.create({
    idleOptions: {
      idleTimeout: 1000 * 60 * 30,
    },
  });
  return authClient;
}


/**
 * Create a new authenticated backend actor
 * @param {import("@dfinity/agent").Identity} identity
 */
export async function createBackendActor(identity) {
  if (!BACKEND_CANISTER_ID) {
    throw new Error('Backend canister ID is not defined.');
  }
  return createActor(BACKEND_CANISTER_ID, {
    agentOptions: {
      // @ts-ignore
      identity,
    },
  });
}