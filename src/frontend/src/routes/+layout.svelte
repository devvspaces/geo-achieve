<script>
	import { page } from '$app/stores';
	import { store } from '$lib/store';
	import { onMount } from 'svelte';
	import '../app.css';
	import {
		Navbar,
		NavBrand,
		NavLi,
		NavUl,
		NavHamburger,
		Spinner,
		GradientButton
	} from 'flowbite-svelte';
	import {
		Footer,
		FooterCopyright,
		FooterLinkGroup,
		FooterLink,
		FooterBrand,
		FooterIcon,
		DarkMode
	} from 'flowbite-svelte';
	import { DiscordSolid, FacebookSolid, GithubSolid, TwitterSolid } from 'flowbite-svelte-icons';
	let { children } = $props();
	let btnClass =
		'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg text-xl p-2';

	/**
	 * @type {Object<string, string>}
	 */
	let paths = {
		'/': 'Home',
		'/profile': 'Profile',
		'/institution': 'Institution',
		'/verify': 'Verify',
		'/dashboard': 'Dashboard',
		'/dashboard/issuers': 'Issuers'
	};

	/**
   * @type ({
    backendActor: typeof import("../../../declarations/backend").backend | null,
    principal: import("@dfinity/principal").Principal | null;
    error: string;
    isLoading: boolean;
  })
 */
	let storeState = $state({
		backendActor: null,
		principal: null,
		error: '',
		isLoading: false
	});
	store.subscribe((value) => {
		storeState = value;
	});

  onMount(async () => {
    await store.checkExistingLoginAndConnect();
  });

	async function connect() {
		await store.internetIdentityConnect();
	}

	async function disconnect() {
		await store.disconnect();
	}
</script>

<div class="p-4">
	<Navbar rounded color="form" class="bg-gray-100 dark:bg-gray-900">
		<NavBrand href="/">
			<span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white"
				>GeoAchieve</span
			>
		</NavBrand>
		<div class="flex space-x-4 md:order-2">
			<DarkMode {btnClass} />
			{#if storeState.principal}
				<GradientButton on:click={disconnect} size="md" color="red">
					<span class="text-md font-semibold">Logout</span>
				</GradientButton>
			{:else}
				<GradientButton on:click={connect} size="md" color="purpleToBlue">
					<img
						src="https://cryptologos.cc/logos/internet-computer-icp-logo.svg?v=035"
						alt="Internet Computer"
						class="mr-2 h-5 w-5"
					/>
					<span class="text-md font-semibold">Login</span>
					<Spinner
						class={`ms-3 ${storeState.isLoading == false && 'hidden'}`}
						size="4"
						color="white"
					/>
				</GradientButton>
			{/if}

			<NavHamburger />
		</div>
		<NavUl class="order-1" activeUrl={$page.url.pathname}>
			{#each Object.keys(paths) as path}
				<NavLi>
					<NavLi href={path}>{paths[path]}</NavLi>
				</NavLi>
			{/each}
		</NavUl>
	</Navbar>

	{@render children()}

	<Footer footerType="socialmedia">
		<hr class="my-6 border-gray-200 sm:mx-auto lg:my-8 dark:border-gray-700" />
		<div class="sm:flex sm:items-center sm:justify-between">
			<FooterCopyright href="/" by="GeoAchieve" />
			<div class="mt-4 flex space-x-6 sm:mt-0 sm:justify-center rtl:space-x-reverse">
				<FooterIcon href="/">
					<FacebookSolid
						class="h-5 w-5 text-gray-500 hover:text-gray-900 dark:text-gray-500 dark:hover:text-white"
					/>
				</FooterIcon>
				<FooterIcon href="/">
					<DiscordSolid
						class="h-5 w-5 text-gray-500 hover:text-gray-900 dark:text-gray-500 dark:hover:text-white"
					/>
				</FooterIcon>
				<FooterIcon href="/">
					<TwitterSolid
						class="h-5 w-5 text-gray-500 hover:text-gray-900 dark:text-gray-500 dark:hover:text-white"
					/>
				</FooterIcon>
				<FooterIcon href="/">
					<GithubSolid
						class="h-5 w-5 text-gray-500 hover:text-gray-900 dark:text-gray-500 dark:hover:text-white"
					/>
				</FooterIcon>
			</div>
		</div>
	</Footer>
</div>
