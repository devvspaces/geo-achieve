<script>
	import { Button, Modal, Label, Input, Fileupload, Spinner } from 'flowbite-svelte';
	import {
		EditOutline,
		LinkedinSolid,
		GithubSolid,
		TwitterSolid,
		YoutubeSolid
	} from 'flowbite-svelte-icons';
	import Editor from '@tinymce/tinymce-svelte';
	import { store } from '$lib/store';

	let conf = {
		height: 200,
		menubar: false,
		plugins: [
			'advlist',
			'autolink',
			'lists',
			'link',
			'image',
			'charmap',
			'anchor',
			'searchreplace',
			'visualblocks',
			'code',
			'fullscreen',
			'insertdatetime',
			'media',
			'table',
			'preview',
			'help',
			'wordcount'
		],
		toolbar:
			'undo redo | blocks | ' +
			'bold italic forecolor | alignleft aligncenter ' +
			'alignright alignjustify | bullist numlist outdent indent | ' +
			'removeformat | help',
		skin: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'oxide-dark' : 'oxide',
		content_css: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default'
	};

	let formModal = $state(false);
	let imageUrl = $state(
		'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Harvard_University_logo.svg/2560px-Harvard_University_logo.svg.png'
	);

	// Function to trigger file upload click
	const triggerFileUpload = () => {
		document.getElementById('profile_image')?.click();
	};

	const handleFileChange = (
		/** @type {{ target: { files: any[]; value: string; }; } | Event} */ event
	) => {
		// @ts-ignore
		if (!event.target?.files) return;
		// @ts-ignore
		const file = event.target?.files[0];

		// Check if a file was selected
		if (!file) return;

		// Validate file type
		const validTypes = ['image/png', 'image/jpeg', 'image/jpg'];
		if (!validTypes.includes(file.type)) {
			alert('Please select a PNG, JPG, or JPEG image');
			// @ts-ignore
			event.target.value = ''; // Reset input
			return;
		}

		// Create preview URL
		const objectUrl = URL.createObjectURL(file);
		imageUrl = objectUrl;

		// Optional: Clean up the old object URL to avoid memory leaks
		return () => {
			URL.revokeObjectURL(objectUrl);
		};
	};

	function updateLocation() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition((position) => {
				formData.latitude = position.coords.latitude.toString();
				formData.longitude = position.coords.longitude.toString();
			});
		} else {
			alert('Geolocation is not supported by this browser.');
		}
	}

	/**
  * @type ({
    backendActor: typeof import("../../../../declarations/backend").backend | null,
    principal: import("@dfinity/principal").Principal | null;
    error: string;
    isLoading: boolean;
    institution: import("../../../../declarations/backend/backend.did").InstitutionUser | null;
    })
  */
	let storeState = $state({
		backendActor: null,
		principal: null,
		error: '',
		isLoading: false,
		institution: null
	});
	store.subscribe((value) => {
		storeState = value;
	});

	$effect(() => {
		if (storeState.institution?.logo.length) {
			// @ts-ignore
			let blob = new Blob([storeState.institution?.logo], { type: 'image/png' });
			let objectUrl = URL.createObjectURL(blob);
			imageUrl = objectUrl;
		}

		formData = {
			name: storeState.institution?.name || '',
			address: storeState.institution?.address || '',
			logo: storeState.institution?.logo ? new Uint8Array(storeState.institution.logo) : null,
			description: storeState.institution?.description || '',
			linkedin: storeState.institution?.linkedin?.length ? storeState.institution?.linkedin[0] : '',
			github: storeState.institution?.github?.length ? storeState.institution?.github[0] : '',
			twitter: storeState.institution?.twitter?.length ? storeState.institution?.twitter[0] : '',
			youtube: storeState.institution?.youtube?.length ? storeState.institution?.youtube[0] : '',
			latitude: storeState.institution?.latitude.toString() || '',
			longitude: storeState.institution?.longitude.toString() || ''
		};
	});

	/**
	 * @type {{
	 *  name: string;
	 * address: string;
	 * logo: Uint8Array | null;
	 * description: string;
	 * linkedin: string;
	 * github: string;
	 * twitter: string;
	 * youtube: string;
	 * latitude: string;
	 * longitude: string;
	 * }}
	 */
	// @ts-ignore
	let formData = $state({
		name: '',
		address: '',
		logo: null,
		description: '',
		linkedin: [],
		github: [],
		twitter: [],
		youtube: [],
		latitude: '',
		longitude: ''
	});

	let isSubmitting = $state(false);
	async function updateInstitution() {
		if (storeState.principal && storeState.backendActor && formData.logo) {
			try {
				isSubmitting = true;
				const response = await storeState.backendActor.update_institution_user({
					name: formData.name,
					address: formData.address,
					logo: formData.logo,
					description: formData.description,
					linkedin: formData.linkedin ? [formData.linkedin] : [],
					github: formData.github ? [formData.github] : [],
					twitter: formData.twitter ? [formData.twitter] : [],
					youtube: formData.youtube ? [formData.youtube] : [],
					latitude: parseFloat(formData.latitude),
					longitude: parseFloat(formData.longitude)
				});
				isSubmitting = false;
				// @ts-ignore
				if (response.ok == null) {
					alert('Account updated successfully');
					store.update((state) => {
						state.institution = {
							...state.institution,
							name: formData.name,
							address: formData.address,
							// @ts-ignore
							logo: formData.logo,
							description: formData.description,
							linkedin: formData.linkedin ? [formData.linkedin] : [],
							github: formData.github ? [formData.github] : [],
							twitter: formData.twitter ? [formData.twitter] : [],
							youtube: formData.youtube ? [formData.youtube] : [],
							latitude: formData.latitude,
							longitude: formData.longitude
						};
						return state;
					});
				} else {
					alert(response.err);
				}
			} catch (error) {
				console.error(error);
			}
		}
	}

	/**
	 * @param {Event} e
	 */
	async function handleSubmit(e) {
		e.preventDefault();
		if (!formData.logo) {
			alert('Please upload an image');
			return;
		}
		if (!formData.latitude || !formData.longitude) {
			alert('Please update location');
			return;
		}
		await updateInstitution();
	}
</script>

<Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#" onsubmit={handleSubmit}>
		<h3 class="mb-2 text-xl font-medium text-gray-900 dark:text-white">Edit Institution Profile</h3>
		<div class="relative mx-auto" style="width: fit-content;">
			<img
				src={imageUrl}
				class="mb-4 bg-gray-300 object-cover shadow-lg"
				alt="John Doe"
				style="width: 100%; max-width: 400px;"
			/>
			<Button
				class="absolute rounded-full !p-2"
				size="sm"
				style="bottom: 30px; right: 10px;"
				on:click={triggerFileUpload}
			>
				<EditOutline class="text-white-700" />
			</Button>
		</div>

		<Fileupload
			id="profile_image"
			class="hidden"
			accept=".png,.jpg,.jpeg"
			on:change={handleFileChange}
		/>
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<Label class="space-y-2">
				<span>Institution name</span>
				<Input
					type="text"
					name="name"
					placeholder="University of Lagos"
					required
					bind:value={formData.name}
				/>
			</Label>
			<Label class="space-y-2">
				<span>Address</span>
				<Input
					type="text"
					name="password"
					placeholder="23, University Road, Akoka, Yaba, Lagos"
					required
					bind:value={formData.address}
				/>
			</Label>
		</div>
		<div class="flex items-end" style="gap: 4rem;">
			<Label class="space-y-2">
				<span>Latitude</span>
				<Input
					type="text"
					name="latitude"
					bind:value={formData.latitude}
					required
				/>
			</Label>
			<Label class="space-y-2">
				<span>Longitude</span>
				<Input
					type="text"
					name="latitude"
					bind:value={formData.longitude}
					required
				/>
			</Label>
			<Button class="ms-auto" on:click={updateLocation} color="purple">Update Location</Button>
		</div>
		<div class="space-y-2">
			<Label for="description" class="mb-2">Description</Label>
			<Editor
				apiKey="wi0le1jhy3ib3c25miowo9cq4rw1rt2z4epba95r1lpwqte0"
				channel="7"
				bind:value={formData.description}
				{conf}
			/>
		</div>
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<Label class="space-y-2">
				<span>LinkedIn</span>
				<Input type="text" name="linkedin" bind:value={formData.linkedin}>
					<LinkedinSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>GitHub</span>
				<Input type="text" name="github" bind:value={formData.github}>
					<GithubSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>X (Formerly Twitter)</span>
				<Input type="text" name="twitter" bind:value={formData.twitter}>
					<TwitterSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>Youtube</span>
				<Input type="text" name="youtube" bind:value={formData.youtube}>
					<YoutubeSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
		</div>
		<Button type="submit" class="w-full1"
			><Spinner
				class={`me-3 ${isSubmitting == false && 'hidden'}`}
				size="4"
				color="white"
			/>Save</Button
		>
	</form>
</Modal>

<div>
	<div class="container mx-auto py-8">
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
							{storeState.institution?.name}
						</h1>
						<p class="mb-3 text-gray-700 dark:text-gray-300">
							{storeState.institution?.address}
						</p>
						<p class="text-gray-700 dark:text-gray-500">{storeState.institution?.id}</p>
						<div class="mt-6 flex space-x-4 text-center" style="width: 100%;">
							<Button on:click={() => (formModal = true)} color="purple" style="width: 100%;"
								>Edit</Button
							>
							<Button color="alternative" style="width: 100%;">Share</Button>
						</div>
					</div>
					<hr class="my-6 border-t border-gray-300" />
					<div class="flex flex-col">
						<span class="mb-2 font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300"
							>Socials</span
						>

						<div class="my-6 flex items-center justify-start gap-6">
							{#if storeState.institution?.linkedin.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.institution?.linkedin[0]}
									target="_blank"
								>
									<LinkedinSolid size="xl" />
								</a>
							{/if}
							{#if storeState.institution?.youtube.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.institution?.youtube[0]}
									target="_blank"
								>
									<YoutubeSolid size="xl" />
								</a>
							{/if}
							{#if storeState.institution?.github.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.institution?.github[0]}
									target="_blank"
								>
									<GithubSolid size="xl" />
								</a>
							{/if}
							{#if storeState.institution?.twitter.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.institution?.twitter[0]}
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
						{@html storeState.institution?.description}
					</p>

					<h2 class="mb-4 mt-10 text-xl font-bold dark:text-white">Location</h2>
					<a
						href={`https://www.google.com/maps/search/?api=1&query=${storeState.institution?.latitude},${storeState.institution?.longitude}`}
						target="_blank"
					>
						<Button color="purple">View on Map</Button>
					</a>
				</div>
			</div>
		</div>
	</div>
</div>
