<script>
	import { page } from '$app/stores';
	import '../app.css';
	import {
		Navbar,
		NavBrand,
		NavLi,
		NavUl,
		NavHamburger,
		Button,
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
  let btnClass = 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg text-xl p-2';

  /**
   * @type {Object<string, string>}
   */
  let paths = {
    '/': 'Home',
    '/profile': 'Profile',
    '/institution': 'Institution',
    '/verify': 'Verify',
    '/dashboard': 'Dashboard',
    '/dashboard/issuers': 'Issuers',
  }
</script>

<div class="p-4">
	<Navbar rounded color="form" class="dark:bg-gray-900 bg-gray-100">
		<NavBrand href="/">
			<span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white"
				>GeoAchieve</span
			>
		</NavBrand>
		<div class="flex space-x-4 md:order-2">
      <DarkMode {btnClass} />
			<GradientButton size="md" color="purpleToBlue">
				<img
					src="https://cryptologos.cc/logos/internet-computer-icp-logo.svg?v=035"
					alt="Internet Computer"
					class="h-5 w-5 mr-2"
				/>
				<span class="font-semibold text-md">Login</span>
			</GradientButton>
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
