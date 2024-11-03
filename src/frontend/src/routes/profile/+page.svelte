<script>
	import {
		Button,
		Timeline,
		TimelineItem,
		Modal,
		Label,
		Input,
		Spinner,
		Fileupload
	} from 'flowbite-svelte';
	import {
		ArrowRightOutline,
		CalendarWeekSolid,
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
	let imageUrl = $state('');

	// Function to trigger file upload click
	const triggerFileUpload = () => {
		document.getElementById('profile_image')?.click();
	};

	const handleFileChange = async (
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

		// Update the form data
		formData.image = new Uint8Array(await file.arrayBuffer());

		// Optional: Clean up the old object URL to avoid memory leaks
		return () => {
			URL.revokeObjectURL(objectUrl);
		};
	};

	/**
 * @type ({
  backendActor: typeof import("../../../../declarations/backend").backend | null,
  principal: import("@dfinity/principal").Principal | null;
  error: string;
  isLoading: boolean;
  recipient: import("../../../../declarations/backend/backend.did").RecipientUser | null;
})
 */
	let storeState = $state({
		backendActor: null,
		principal: null,
		error: '',
		isLoading: false,
		recipient: null
	});
	store.subscribe((value) => {
		storeState = value;
	});

	$effect(() => {
		if (storeState.recipient?.image.length) {
			// @ts-ignore
			let blob = new Blob([storeState.recipient?.image], { type: 'image/png' });
			let objectUrl = URL.createObjectURL(blob);
			imageUrl = objectUrl;
		}

		formData = {
			name: storeState.recipient?.name || '',
			tagline: storeState.recipient?.tagline || '',
			image: storeState.recipient?.image ? new Uint8Array(storeState.recipient.image) : null,
			description: storeState.recipient?.description || '',
			linkedin: storeState.recipient?.linkedin?.length ? storeState.recipient?.linkedin[0] : "",
			github: storeState.recipient?.github?.length ? storeState.recipient?.github[0] : "",
			twitter: storeState.recipient?.twitter?.length ? storeState.recipient?.twitter[0] : "",
			youtube: storeState.recipient?.youtube?.length ? storeState.recipient?.youtube[0] : ""
		};
	});

	/**
	 * @type {{
	 *  name: string;
	 * tagline: string;
	 * image: Uint8Array | null;
	 * description: string;
	 * linkedin: string;
	 * github: string;
	 * twitter: string;
	 * youtube: string;
	 * }}
	 */
	// @ts-ignore
	let formData = $state({
		name: '',
		tagline: '',
		image: null,
		description: '',
		linkedin: [],
		github: [],
		twitter: [],
		youtube: []
	});

	let isSubmitting = $state(false);
	async function updateRecipient() {
		if (storeState.principal && storeState.backendActor && formData.image) {
			try {
				isSubmitting = true;
				const response = await storeState.backendActor.update_recipient_user({
					name: formData.name,
					tagline: formData.tagline,
					image: formData.image,
					description: formData.description,
					linkedin: formData.linkedin ? [formData.linkedin] : [],
					github: formData.github ? [formData.github] : [],
					twitter: formData.twitter ? [formData.twitter] : [],
					youtube: formData.youtube ? [formData.youtube] : []
				});
				isSubmitting = false;
				// @ts-ignore
				if (response.ok == null) {
					alert('Account updated successfully');
          store.update((state) => {
            state.recipient = {
              ...state.recipient,
              name: formData.name,
              tagline: formData.tagline,
              // @ts-ignore
              image: formData.image,
              description: formData.description,
              linkedin: formData.linkedin ? [formData.linkedin] : [],
              github: formData.github ? [formData.github] : [],
              twitter: formData.twitter ? [formData.twitter] : [],
              youtube: formData.youtube ? [formData.youtube] : []
            }
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
		if (!formData.image) {
			alert('Please upload an image');
			return;
		}
		await updateRecipient();
	}
</script>

<Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#" onsubmit={handleSubmit}>
		<h3 class="mb-2 text-xl font-medium text-gray-900 dark:text-white">Profile</h3>
		<div class="relative mx-auto" style="width: fit-content;">
			<img
				src={imageUrl}
				class="mb-4 rounded-full bg-gray-300 object-cover shadow-lg"
				alt="John Doe"
				style="width: 200px; height: 200px;"
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
				<span>Full name</span>
				<Input type="text" name="name" placeholder="John Doe" required bind:value={formData.name} />
			</Label>
			<Label class="space-y-2">
				<span>Tagline</span>
				<Input
					type="text"
					name="tagline"
					placeholder="Software Engineer"
					required
					bind:value={formData.tagline}
				/>
			</Label>
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
			/>Update</Button
		>
	</form>
</Modal>

<div>
	<div class="container mx-auto py-8">
		<div class="grid grid-cols-4 gap-6 px-4 sm:grid-cols-12">
			<div class="col-span-4 sm:col-span-3">
				<div class="sticky top-0 rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<div class="flex flex-col items-center">
						<img
							src={imageUrl}
							style="width: 200px; height: 200px;"
							class="mb-4 shrink-0 rounded-full bg-gray-300 object-cover shadow-lg"
							alt={storeState.recipient?.name}
						/>
						<h1 class="text-xl font-bold text-gray-900 dark:text-white">
							{storeState.recipient?.name}
						</h1>
						<p class="mb-3 text-gray-700 dark:text-gray-300">{storeState.recipient?.tagline}</p>
						<p class="text-gray-700 dark:text-gray-500">
							Principal: {storeState.principal?.toText()}
						</p>
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
							>Connect</span
						>

						<div class="my-6 flex items-center justify-start gap-6">
							{#if storeState.recipient?.linkedin.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.recipient?.linkedin[0]}
									target="_blank"
								>
									<LinkedinSolid size="xl" />
								</a>
							{/if}
							{#if storeState.recipient?.youtube.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.recipient?.youtube[0]}
									target="_blank"
								>
									<YoutubeSolid size="xl" />
								</a>
							{/if}
							{#if storeState.recipient?.github.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.recipient?.github[0]}
									target="_blank"
								>
									<GithubSolid size="xl" />
								</a>
							{/if}
							{#if storeState.recipient?.twitter.length}
								<a
									class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
									aria-label="Visit TrendyMinds LinkedIn"
									href={storeState.recipient?.twitter[0]}
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
						{@html storeState.recipient?.description}
					</p>

					<h2 class="mb-4 mt-10 text-xl font-bold dark:text-white">Achievements</h2>

					<Timeline order="vertical">
						<TimelineItem title="BSc Computer Science" date="February 2022">
							<svelte:fragment slot="icon">
								<span
									class="bg-primary-200 dark:bg-primary-900 absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full ring-8 ring-white dark:ring-gray-900"
								>
									<CalendarWeekSolid class="text-primary-600 dark:text-primary-400 h-4 w-4" />
								</span>
							</svelte:fragment>
							<p class="mb-2 text-base font-normal text-gray-500 dark:text-gray-400">
								Graduated with a BSc in Computer Science from North Carolina State University.
							</p>
							<p class="mb-2 text-base font-normal text-gray-500 dark:text-gray-400">
								North Carolina State University
							</p>
							<p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">
								Location: Raleigh, North Carolina
							</p>
							<a href="/certificate/1">
								<Button color="alternative">View<ArrowRightOutline class="ms-2 h-5 w-5" /></Button>
							</a>
						</TimelineItem>
						<TimelineItem date="March 2022" title="Application UI code in Tailwind CSS">
							<svelte:fragment slot="icon">
								<span
									class="bg-primary-200 dark:bg-primary-900 absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full ring-8 ring-white dark:ring-gray-900"
								>
									<CalendarWeekSolid class="text-primary-600 dark:text-primary-400 h-4 w-4" />
								</span>
							</svelte:fragment>
							<p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">
								Get access to over 20+ pages including a dashboard layout, charts, kanban board,
								calendar, and pre-order E-commerce & Marketing pages.
							</p>
							<Button color="alternative"
								>Learn more<ArrowRightOutline class="ms-2 h-5 w-5" /></Button
							>
						</TimelineItem>
						<TimelineItem title="Application UI code in Tailwind CSS" date="April 2022">
							<svelte:fragment slot="icon">
								<span
									class="bg-primary-200 dark:bg-primary-900 absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full ring-8 ring-white dark:ring-gray-900"
								>
									<CalendarWeekSolid class="text-primary-600 dark:text-primary-400 h-4 w-4" />
								</span>
							</svelte:fragment>
							<p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">
								Get started with dozens of web components and interactive elements built on top of
								Tailwind CSS.
							</p>
							<Button color="alternative"
								>Learn more<ArrowRightOutline class="ms-2 h-5 w-5" /></Button
							>
						</TimelineItem>
					</Timeline>
				</div>
			</div>
		</div>
	</div>
</div>
