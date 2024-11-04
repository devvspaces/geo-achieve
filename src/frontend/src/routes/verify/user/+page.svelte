<script>
	import {
		Button,
		Timeline,
		TimelineItem,
		Spinner,
		Badge
	} from 'flowbite-svelte';
	import {
		ArrowRightOutline,
		CalendarWeekSolid,
		LinkedinSolid,
		GithubSolid,
		TwitterSolid,
		YoutubeSolid
	} from 'flowbite-svelte-icons';
	import { convertArrayToObjects, createBackendNoIdentity } from '$lib/utils';
	import { createGeoNft } from '$lib/utils';
	import { Principal } from '@dfinity/principal';
	import { page } from '$app/stores';

	let imageUrl = $state('');

	/**
	 * @type {(import("../../../../../declarations/backend/backend.did").RecipientUser | undefined)}
	 */
	let recipient = $state();

	let user_id = $page.url.searchParams.get('id');

	$effect(() => {
		if (recipient?.image.length) {
			// @ts-ignore
			let blob = new Blob([recipient.image], { type: 'image/png' });
			let objectUrl = URL.createObjectURL(blob);
			imageUrl = objectUrl;
		}
	});

	/**
	 * @type {any[]}
	 */
	const certificates = $state([]);

	let isLoading = $state(false);

	$effect(() => {
		if (!user_id) {
			return;
		}

		/**
		 * @type {Principal}
		 */
		let principal;

		try {
			principal = Principal.fromText(user_id);
		} catch (error) {
			alert('Invalid User ID');
			return;
		}

		(async () => {
			isLoading = true;
			const geoNft = await createGeoNft();
			const backendActor = await createBackendNoIdentity();

      // Load user
			const response = await backendActor.get_recipient_user_by_principal(principal);
			// @ts-ignore
			if (response.ok) {
				// @ts-ignore
				recipient = response.ok;
			}

			let myNfts = await geoNft.icrc7_tokens_of(
				{
					owner: principal,
					subaccount: []
				},
				[],
				[]
			);
			let token_ids = myNfts;
			try {
				const result = await geoNft.icrc7_token_metadata(token_ids);
				// @ts-ignore
				// @ts-ignore
				const tokens = result;
				const data = tokens.map((item) => convertArrayToObjects(item));
				console.log(data);
				for (let i = 0; i < data.length; i++) {
					/**
					 * @type {any}
					 */
					let certificate = {};
					if (!data[i]) {
						continue;
					}
					// @ts-ignore
					let issued_on = data[i].issued_on;
					certificate['id'] = Number(token_ids[i]).toString();
					certificate['issued_on'] = issued_on
						? new Date(Number(issued_on) / 1000000).toDateString()
						: 'N/A';
					// @ts-ignore
					certificate['name'] = data[i].name;
					// @ts-ignore
					certificate['issued_to'] = data[i].recipient_name;
					// @ts-ignore
					certificate.category = data[i].kind;

					// @ts-ignore
					let institutionT = data[i].institution;
					// @ts-ignore
					if (data[i].institution?.constructor?.name == 'Uint8Array') {
						// @ts-ignore
						institutionT = Principal.fromUint8Array(data[i].institution).toText();
					}

					if (institutionT) {
						const response = await backendActor.get_institution_user_by_principal(
							Principal.fromText(institutionT)
						);
						// @ts-ignore
						if (response.ok) {
							/**
							 * @type {import("../../../../../declarations/backend/backend.did").InstitutionUser}
							 */
							// @ts-ignore
							const institution = response.ok;
							certificate['institution'] = institution.name;
							certificate['location'] = institution.address;
						}
					}

					certificates.push(certificate);
				}
			} catch (error) {
				console.error(error);
			}
			isLoading = false;
		})();
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
						<img
							src={imageUrl}
							style="width: 200px; height: 200px;"
							class="mb-4 shrink-0 rounded-full bg-gray-300 object-cover shadow-lg"
							alt={recipient?.name}
						/>
						<h1 class="text-xl font-bold text-gray-900 dark:text-white">
							{recipient?.name}
						</h1>
						<p class="mb-3 text-gray-700 dark:text-gray-300">{recipient?.tagline}</p>
						<p class="text-gray-700 dark:text-gray-500 text-center">
							Principal: {user_id}
						</p>
						<div class="mt-6 flex space-x-4 text-center" style="width: 100%;">
							<Button color="alternative" style="width: 100%;">Share</Button>
						</div>
					</div>
					<hr class="my-6 border-t border-gray-300" />
					<div class="flex flex-col">
						<span class="mb-2 font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300"
							>Connect</span
						>

						<div class="my-6 flex items-center justify-start gap-6">
							{#if recipient?.linkedin.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={recipient?.linkedin[0]}
									target="_blank"
								>
									<LinkedinSolid size="xl" />
								</a>
							{/if}
							{#if recipient?.youtube.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={recipient?.youtube[0]}
									target="_blank"
								>
									<YoutubeSolid size="xl" />
								</a>
							{/if}
							{#if recipient?.github.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={recipient?.github[0]}
									target="_blank"
								>
									<GithubSolid size="xl" />
								</a>
							{/if}
							{#if recipient?.twitter.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={recipient?.twitter[0]}
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
						{@html recipient?.description}
					</p>

					<h2 class="mb-4 mt-10 text-xl font-bold dark:text-white">Achievements</h2>

					<Timeline order="vertical">
						{#each certificates as cert}
							<TimelineItem title={cert.name} date={cert.issued_on}>
								<svelte:fragment slot="icon">
									<span
										class="bg-primary-200 dark:bg-primary-900 absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full ring-8 ring-white dark:ring-gray-900"
									>
										<CalendarWeekSolid class="text-primary-600 dark:text-primary-400 h-4 w-4" />
									</span>
								</svelte:fragment>
								<Badge class="my-2" border color="green">{cert.category}</Badge>
								<p class="mb-2 text-base font-normal text-gray-500 dark:text-gray-400">
									{cert.institution}
								</p>
								<p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">
									Location: {cert.location}
								</p>
								<a href={`/certificate?id=${cert.id}`}>
									<Button color="alternative">View<ArrowRightOutline class="ms-2 h-5 w-5" /></Button
									>
								</a>
							</TimelineItem>
						{/each}
					</Timeline>
				</div>
			</div>
		</div>
	</div>
</div>
