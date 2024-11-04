import { writable } from 'svelte/store';
import { AuthClient } from '@dfinity/auth-client';
import { createActor as createBackendCanisterActor } from '../../../declarations/backend';
import { BACKEND_CANISTER_ID, getHost, createBackendActor, getIdentityProvider } from './utils';
import { goto } from '$app/navigation';

export const HOST = getHost();

/**
 * @type {AuthClient}
 */
let authClient;

const days = BigInt(30);
const hours = BigInt(24);
const nanosecondsPerHour = BigInt(3600000000000);

if (!BACKEND_CANISTER_ID) {
	throw new Error('Backend canister ID is not defined.');
}

/**
 * @type ({
  backendActor: typeof import("../../../declarations/backend").backend | null,
  principal: import("@dfinity/principal").Principal | null;
  error: string;
  isLoading: boolean;
  recipient: import("../../../declarations/backend/backend.did").RecipientUser | null;
  institution: import("../../../declarations/backend/backend.did").InstitutionUser | null;
})
 */
const defaultState = {
	backendActor: createBackendCanisterActor(BACKEND_CANISTER_ID, {
		agentOptions: { host: HOST }
	}),
	principal: null,
	error: '',
	isLoading: false,
	recipient: null,
	institution: null
};

export const createStore = () => {
	const { subscribe, update } = writable(defaultState);

	/**
	 *
	 * @param {(() => Promise<void>) | null} onSuccess
	 * @param {(() => Promise<void>) | null} onError
	 */
	const internetIdentityConnect = async (onSuccess = null, onError = null) => {
		authClient = await AuthClient.create();
		if (await authClient.isAuthenticated()) {
			const identity = authClient.getIdentity();
			initInternetIdentity(identity);
		} else {
			update((state) => ({
				...state,
				isLoading: true
			}));
			await authClient.login({
				onError: async () => {
					update((state) => ({
						...state,
						isLoading: false
					}));
					onError && (await onError());
				},
				onSuccess: async () => {
					update((state) => ({
						...state,
						isLoading: false
					}));
					const identity = authClient.getIdentity();
					initInternetIdentity(identity);
					onSuccess && (await onSuccess());
				},
				identityProvider: getIdentityProvider(),
				// Maximum authorization expiration is 30 days
				maxTimeToLive: days * hours * nanosecondsPerHour,
				windowOpenerFeatures:
					`left=${window.screen.width / 2 - 525 / 2}, ` +
					`top=${window.screen.height / 2 - 705 / 2},` +
					`toolbar=0,location=0,menubar=0,width=525,height=705`
			});
		}
	};

	const initInternetIdentity = async (
		/** @type {import("@dfinity/agent").Identity | null} */ identity
	) => {
    if (!identity) {
      const authClient = await AuthClient.create();
      identity = authClient.getIdentity();
    }
		const backendActor = await createBackendActor(identity);

		if (!backendActor) {
			console.warn("couldn't create backend actor");
			return;
		}

		let recipient = null;
		let institution = null;

		// Check if user exists
		try {
			/**
			 * @type {{
			 *  ok?: { Institution: null; Recipient: null; };
			 *  err?: string;
			 * }}
			 */
			// @ts-ignore
			const user = await backendActor.get_user_type();
        console.log(user);
        if (user.ok) {
				// @ts-ignore
				if (Object.keys(user.ok).indexOf('Institution') !== -1) {
					const response = await backendActor.get_institution_user();
					if (!response) return;
					// @ts-ignore
					if (response.ok) {
						// @ts-ignore
						institution = response.ok;
					}
					// if (!window.location.pathname.startsWith('/institution')) {
					// 	goto('/institution', { replaceState: true });
					// }
				} else {
					const response = await backendActor.get_recipient_user();
					if (!response) return;
					// @ts-ignore
					if (response.ok) {
						// @ts-ignore
						recipient = response.ok;
					}
					// if (!window.location.pathname.startsWith('/profile')) {
					// 	goto('/profile', { replaceState: true });
					// }
				}
			} else {
				if (!window.location.pathname.startsWith('/register')) {
					goto('/register', { replaceState: true });
				}
			}
		} catch (error) {
			console.error('Error checking user:', error);
		}

		update((state) => ({
			...state,
			backendActor,
			principal: identity.getPrincipal(),
			recipient,
			institution
		}));

		console.log('Connected to Internet Identity');
	};

	const disconnect = async () => {
		try {
			await authClient.logout();
			localStorage.clear();
		} catch (error) {
			console.error('Internet Identity disconnect error: ', error);
		}

		update(() => {
			return {
				...defaultState
			};
		});
	};

	/**
	 *
	 * @param {(() => Promise<void>) | null} onSuccess
	 * @param {(() => Promise<void>) | null} onError
	 */
	const checkExistingLoginAndConnect = async (onSuccess = null, onError = null) => {
		// Check login state if user is already logged in
		authClient = await AuthClient.create();
		if (await authClient.isAuthenticated()) {
			const identity = authClient.getIdentity();
			await initInternetIdentity(identity);
			onSuccess && (await onSuccess());
		} else {
			onError && (await onError());
		}
	};

	return {
		subscribe,
		update,
		internetIdentityConnect,
		disconnect,
		checkExistingLoginAndConnect,
    initInternetIdentity
	};
};

export const store = createStore();
