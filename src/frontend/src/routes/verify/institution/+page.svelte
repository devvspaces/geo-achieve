<script>
	import { page } from '$app/stores';
	import { createBackendNoIdentity } from '$lib/utils';
	import { Principal } from '@dfinity/principal';
	import { Button, Spinner } from 'flowbite-svelte';
	import { LinkedinSolid, GithubSolid, TwitterSolid, YoutubeSolid } from 'flowbite-svelte-icons';
	import { onMount } from 'svelte';

	let imageUrl = $state('');

	let institution_id = $page.url.searchParams.get('id');

	/**
	 * @type {(import("../../../../../declarations/backend/backend.did").InstitutionUser | undefined)}
	 */
	let institution = $state();

	$effect(() => {
		if (institution) {
			// @ts-ignore
			let blob = new Blob([institution.logo], { type: 'image/png' });
			let objectUrl = URL.createObjectURL(blob);
			imageUrl = objectUrl;
		}
	});

	let isLoading = $state(false);
	async function loadInstitution() {
		if (!institution_id) {
			return;
		}
		isLoading = true;
		const backendActor = await createBackendNoIdentity();
		try {

      /**
       * @type {Principal}
       */
      let institution_p;

      try {
        institution_p = Principal.fromText(institution_id)
      } catch (error) {
        alert('Invalid Institution ID');
        return;
      }

			const response = await backendActor.get_institution_user_by_principal(institution_p);
			// @ts-ignore
			if (response.ok) {
				/**
				 * @type {import("../../../../../declarations/backend/backend.did").InstitutionUser}
				 */
				// @ts-ignore
				institution = response.ok;
			}
		} catch (error) {
			console.error(error);
		}
		isLoading = false;
	}

	onMount(async () => {
		await loadInstitution();
	});
</script>

<div>
	<div class="container mx-auto py-8">
		<div class="mb-4 flex items-center justify-center">
			<Spinner class={`me-3 ${isLoading == false && 'hidden'}`} size="8" color="white" />
		</div>
		<div class="grid grid-cols-4 gap-6 px-4 sm:grid-cols-12">
			<div class="col-span-4 sm:col-span-3">
				<div class="sticky top-0 rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<div class="flex flex-col items-center">
						<div>
							<img
								src={imageUrl}
								class="mb-4 w-full shrink-0 rounded bg-white object-cover p-4"
								alt="University of Lagos"
							/>
						</div>
						<h1 class="text-xl font-bold text-gray-900 dark:text-white">
							{institution?.name}
						</h1>
						<p class="mb-3 text-gray-700 dark:text-gray-300">
							{institution?.address}
						</p>
						<p class="text-gray-700 dark:text-gray-500 text-center">{institution_id}</p>
						<div class="mt-6 flex space-x-4 text-center" style="width: 100%;">
							<Button color="alternative" style="width: 100%;">Share</Button>
						</div>
					</div>
					<hr class="my-6 border-t border-gray-300" />
					<div class="flex flex-col">
						<span class="mb-2 font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300"
							>Socials</span
						>

						<div class="my-6 flex items-center justify-start gap-6">
							{#if institution?.linkedin.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={institution?.linkedin[0]}
									target="_blank"
								>
									<LinkedinSolid size="xl" />
								</a>
							{/if}
							{#if institution?.youtube.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={institution?.youtube[0]}
									target="_blank"
								>
									<YoutubeSolid size="xl" />
								</a>
							{/if}
							{#if institution?.github.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={institution?.github[0]}
									target="_blank"
								>
									<GithubSolid size="xl" />
								</a>
							{/if}
							{#if institution?.twitter.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={institution?.twitter[0]}
									target="_blank"
								>
									<TwitterSolid size="xl" />
								</a>
							{/if}
						</div>
					</div>
				</div>
			</div>
			<div class="col-span-4 sm:col-span-9">
				<div class="rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<h2 class="mb-4 text-xl font-bold dark:text-white">Hello! 👋.</h2>
					<p class="text-gray-700 dark:text-gray-300">
						{@html institution?.description}
					</p>

					<h2 class="mb-4 mt-10 text-xl font-bold dark:text-white">Location</h2>
					<a
						href={`https://www.google.com/maps/search/?api=1&query=${institution?.latitude},${institution?.longitude}`}
						target="_blank"
					>
						<Button color="purple">View on Map</Button>
					</a>
				</div>
			</div>
		</div>
	</div>
</div>
