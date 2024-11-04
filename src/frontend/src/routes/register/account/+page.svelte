<script>
	import { Card, Button, Label, Input, Fileupload, Spinner } from 'flowbite-svelte';
	import {
		EditOutline,
		LinkedinSolid,
		GithubSolid,
		TwitterSolid,
		YoutubeSolid
	} from 'flowbite-svelte-icons';
	import Editor from '@tinymce/tinymce-svelte';
	import { store } from '$lib/store';
	import { goto } from '$app/navigation';

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
	let formData = $state({
		name: '',
		tagline: '',
		image: null,
		description: '<p>Hello, Talk about yourself <strong>here</strong>...</p>',
		linkedin: '',
		github: '',
		twitter: '',
		youtube: ''
	});

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

	let imageUrl = $state('https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png');

	// Function to trigger file upload click
	const triggerFileUpload = () => {
		document.getElementById('profile_image')?.click();
	};

	const handleFileChange = async (
		/** @type {{ target: { files: any[]; value: string; }; } | Event} */ event
	) => {
		// @ts-ignore
		if (!event.target?.files) return;

		/**
		 * @type {File | undefined}
		 */
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
  backendActor: typeof import("../../../../../declarations/backend").backend | null,
  principal: import("@dfinity/principal").Principal | null;
  error: string;
})
*/
	let storeState = $state({
		backendActor: null,
		principal: null,
		error: ''
	});
	store.subscribe((value) => {
		storeState = value;
	});

	let isSubmitting = $state(false);

	async function createRecipient() {
		if (storeState.principal && storeState.backendActor && formData.image) {
			try {
				isSubmitting = true;
				const response = await storeState.backendActor.add_recipient_user({
					name: formData.name,
					tagline: formData.tagline,
					image: formData.image,
					description: formData.description,
					linkedin: formData.linkedin ? [formData.linkedin] : [],
					github: formData.github ? [formData.github] : [],
					twitter: formData.twitter ? [formData.twitter] : [],
					youtube: formData.youtube ? [formData.youtube] : []
				});
				// @ts-ignore
				if (response.err) {
					isSubmitting = false;
					// @ts-ignore
					alert(response.err);
				} else {
					await store.initInternetIdentity();
					isSubmitting = false;
					alert('Account created successfully');
					// Redirect to the dashboard
					goto('/profile', { replaceState: true });
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

		if (!storeState.principal) {
			// Redirect to login page
			await store.internetIdentityConnect(async () => {
				await createRecipient();
			});
		} else {
			await createRecipient();
		}
	}
</script>

<div
	style="min-height: calc(100vh - 15rem);"
	class="container mx-auto flex max-w-screen-xl flex-col items-center justify-center px-4 py-8 lg:px-12"
>
	<Card size="lg">
		<form class="flex flex-col space-y-6" action="#" onsubmit={handleSubmit}>
			<h3 class="mb-2 text-center text-xl font-medium text-gray-900 dark:text-white">
				Create New GeoAchieve Account
			</h3>
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
					color="purple"
					on:click={triggerFileUpload}
				>
					<EditOutline class="text-white-700" />
				</Button>
			</div>

			<Fileupload
				id="profile_image"
				class="hidden"
				name="profile_image"
				accept=".png,.jpg,.jpeg"
				on:change={handleFileChange}
			/>
			<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
				<Label class="space-y-2">
					<span>Full name</span>
					<Input
						type="text"
						name="name"
						placeholder="John Doe"
						required
						bind:value={formData.name}
					/>
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
			<Button color="purple" type="submit" class="w-full1"
				><Spinner
					class={`me-3 ${isSubmitting == false && 'hidden'}`}
					size="4"
					color="white"
				/>Register</Button
			>
		</form>
	</Card>
</div>
