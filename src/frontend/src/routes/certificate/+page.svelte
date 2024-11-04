<script>
	import { page } from '$app/stores';
	import { convertArrayToObjects, createBackendNoIdentity, createGeoNft } from '$lib/utils';
	import { Principal } from '@dfinity/principal';
	import { Avatar, Button, Card, Spinner, GradientButton } from 'flowbite-svelte';
	import { ArrowRightOutline, CalendarWeekSolid } from 'flowbite-svelte-icons';
	import { onMount } from 'svelte';

	/**
	 * @type {any}
	 */
	const certificate = $state({
		'Issued to': '',
		Category: '',
		Institution: '',
		Name: '',
		Location: '',
		'Certificate ID': '',
		'Issued on': 'N/A',
	});

  let token_id = $page.url.searchParams.get('id');
  let institution_id = $state('');
  
	/**
	 * @type {any}
	 */
	const files = $state({
    "Logo": "",
    "Image": ""
	});

	let isLoading = $state(false);
	async function loadCert() {
    if (!token_id) {
      return;
    }
		isLoading = true;
		const geoNft = await createGeoNft();
		const backendActor = await createBackendNoIdentity();
		let token_ids = [BigInt(token_id)];
		try {
			const result = await geoNft.icrc7_token_metadata(token_ids);
			// @ts-ignore
			// @ts-ignore
			const tokens = result;
			const data = tokens.map((item) => convertArrayToObjects(item));
			console.log(data);
			for (let i = 0; i < data.length; i++) {
				if (!data[i]) {
          alert('Certificate not found');
					continue;
				}
				// @ts-ignore
				let issued_on = data[i].issued_on;
				certificate['Certificate ID'] = Number(token_ids[i]).toString();
				certificate['Issued on'] = issued_on ? new Date(Number(issued_on) / 1000000) : 'N/A';
				// @ts-ignore
				certificate['Name'] = data[i].name;
				// @ts-ignore
				certificate['Issued to'] = data[i].recipient_name;
				// @ts-ignore
        certificate.Category = data[i].kind;

				// @ts-ignore
				let institutionT = data[i].institution;
				// @ts-ignore
				if (data[i].institution.constructor.name == 'Uint8Array') {
					// @ts-ignore
					institutionT = Principal.fromUint8Array(data[i].institution).toText();
				}

        institution_id = institutionT;

        // @ts-ignore
				if (data[i].image.constructor.name == 'Uint8Array') {
				  // @ts-ignore
          let imageBlob = new Blob([new Uint8Array(data[i].image)], { type: 'image/png' });
					files['Image'] = URL.createObjectURL(imageBlob);
				}

				const response = await backendActor.get_institution_user_by_principal(
					Principal.fromText(institutionT)
				);
				// @ts-ignore
				if (response.ok) {
					/**
					 * @type {import("../../../../declarations/backend/backend.did").InstitutionUser}
					 */
					// @ts-ignore
					const institution = response.ok;
					certificate['Institution'] = institution.name;
					certificate['Location'] = institution.address;
          let blob = new Blob([new Uint8Array(institution.logo)], { type: 'image/png' });
          let objectUrl = URL.createObjectURL(blob);
					files['Logo'] = objectUrl;
				}
			}
		} catch (error) {
			console.error(error);
		}
		isLoading = false;
	}

	onMount(async () => {
		await loadCert();
	});
</script>

<div>
	<div class="container mx-auto py-8">
    <div class="flex justify-center items-center mb-4">
      <Spinner class={`me-3 ${isLoading == false && 'hidden'}`} size='8' color="white" />
    </div>
		<div class="grid grid-cols-4 gap-6 px-4 sm:grid-cols-12">
			<div class="col-span-4 sm:col-span-3">
				<div class="sticky top-0 rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<div class="flex flex-col gap-4">
						{#each Object.keys(certificate) as key}
							<div class="flex justify-between">
								<span
									style="font-size: 1.1rem;"
									class="w-30 inline-block font-semibold text-gray-800 dark:text-gray-100"
									>{key}:
								</span>
								<span class="text-right font-medium text-gray-700 dark:text-gray-300">
									{certificate[key]}</span
								>
							</div>
						{/each}
					</div>
					<hr class="my-6 border-t border-gray-300 dark:border-gray-700" />
					<div class="flex flex-col">
						<span
							class="mb-4 text-center font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300"
							>This certificate has been issued by</span
						>
						<div class="mb-8 flex justify-center rounded-lg bg-white p-4 shadow">
							<img
								src={files.Logo}
								class="w-full shrink-0"
								alt={certificate.Institution}
							/>
						</div>
						<div class="flex flex-wrap justify-center gap-4">
							<a href={`/verify/institution?id=${institution_id}`}>
                <GradientButton size="md" color="purple" style="width: 100%">
                  <span class="text-md font-semibold">View</span>
                  <ArrowRightOutline class="ms-2 h-5 w-5" />
                </GradientButton>
              </a>
						</div>
					</div>
				</div>
			</div>
			<div class="col-span-4 sm:col-span-9">
				<div class="rounded-lg bg-gray-50 p-6 shadow dark:bg-gray-900">
					<img
						src={files.Image}
						class="rounded"
						alt="Certificate"
					/>

					<h2 class="mb-4 mt-6 text-lg font-semibold dark:text-gray-100">{token_id}</h2>
					<p class="text-sm text-gray-700 dark:text-gray-300">
						Verify at <a
							href={`https://verify.com/certificate?id=${token_id}`}
							class="text-slate-700 underline dark:text-gray-300"
							>https://verify.com/certificate?id={token_id}</a
						>
					</p>
				</div>
			</div>
		</div>
	</div>
</div>
