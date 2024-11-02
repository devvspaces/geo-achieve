<script>
	import { Button, Modal, Label, Input, Fileupload } from 'flowbite-svelte';
	import {
		EditOutline,
		LinkedinSolid,
		GithubSolid,
		TwitterSolid,
		YoutubeSolid
	} from 'flowbite-svelte-icons';
	import Editor from '@tinymce/tinymce-svelte';

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

	let latitude = $state(3.3730805);
	let longitude = $state(3.3730805);

	function updateLocation() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition((position) => {
				latitude = position.coords.latitude;
				longitude = position.coords.longitude;
			});
		} else {
			alert('Geolocation is not supported by this browser.');
		}
	}
</script>

<Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#">
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
				<Input type="text" name="name" placeholder="University of Lagos" required />
			</Label>
			<Label class="space-y-2">
				<span>Address</span>
				<Input
					type="text"
					name="password"
					placeholder="23, University Road, Akoka, Yaba, Lagos"
					required
				/>
			</Label>
		</div>
		<div class="flex items-end" style="gap: 4rem;">
			<Label class="space-y-2">
				<span>Latitude</span>
				<Input type="number" name="latitude" class="hidden" bind:value={latitude} required />
				<p>{latitude}</p>
			</Label>
			<Label class="space-y-2">
				<span>Longitude</span>
				<Input type="number" name="latitude" class="hidden" bind:value={longitude} required />
				<p>{longitude}</p>
			</Label>
			<Button class="ms-auto" on:click={updateLocation} color="purple">Update Location</Button>
		</div>
		<div class="space-y-2">
			<Label for="description" class="mb-2">Description</Label>
			<Editor
				apiKey="wi0le1jhy3ib3c25miowo9cq4rw1rt2z4epba95r1lpwqte0"
				channel="7"
				value="<p>Hello, Talk about your institution here.</p>"
				{conf}
			/>
		</div>
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<Label class="space-y-2">
				<span>LinkedIn</span>
				<Input type="text" name="linkedin" placeholder="">
					<LinkedinSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>GitHub</span>
				<Input type="text" name="github" placeholder="">
					<GithubSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>X (Formerly Twitter)</span>
				<Input type="text" name="twitter" placeholder="">
					<TwitterSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
			<Label class="space-y-2">
				<span>Youtube</span>
				<Input type="text" name="youtube" placeholder="">
					<YoutubeSolid slot="left" class="h-4 w-4" />
				</Input>
			</Label>
		</div>
		<Button type="submit" class="w-full1">Save</Button>
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
								src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Harvard_University_logo.svg/2560px-Harvard_University_logo.svg.png"
								class="mb-4 w-full shrink-0 rounded bg-white object-cover p-4"
								alt="University of Lagos"
							/>
						</div>
						<h1 class="text-xl font-bold text-gray-900 dark:text-white">University of Lagos</h1>
						<p class="mb-3 text-gray-700 dark:text-gray-300">
							23, University Road, Akoka, Yaba, Lagos
						</p>
						<p class="text-gray-700 dark:text-gray-500">1234-5678-9101-1121</p>
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
							<a
								class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
								aria-label="Visit TrendyMinds LinkedIn"
								href="#"
								target="_blank"
							>
								<LinkedinSolid size="xl" />
							</a>
							<a
								class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
								aria-label="Visit TrendyMinds YouTube"
								href="#"
								target="_blank"
							>
								<YoutubeSolid size="xl" />
							</a>
							<a
								class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
								aria-label="Visit TrendyMinds Facebook"
								href=""
								target="_blank"
							>
								<GithubSolid size="xl" />
							</a>
							<a
								class="text-gray-700 hover:text-orange-600 dark:text-gray-300 dark:hover:text-orange-600"
								aria-label="Visit TrendyMinds Twitter"
								href=""
								target="_blank"
							>
								<TwitterSolid size="xl" />
							</a>
						</div>
					</div>
				</div>
			</div>
			<div class="col-span-4 sm:col-span-9">
				<div class="rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<h2 class="mb-4 text-xl font-bold dark:text-white">Hello! 👋.</h2>
					<p class="text-gray-700 dark:text-gray-300">
						I love building open source projects, learning, and teaching in public through the 570
						words I’ve written on thecodeway.hashnode.dev. You might like my latest blog post: What
						Exactly Is Neo's Built-In Oracle Service. You can subscribe to my blog RSS or follow me
						at thecodeway.hashnode.dev.

						<br />
						<br />
						🔭 I’m currently working as a Senior Software Engineer at GetG3ms.
						<br />
						🌱 I’m building various tools using Golang, Rust, Python and Typescript.
						<br />
						💬 Ask me about Backend, Frontend, Cloud and DevOps.
						<br />
						📫 How to reach me: LinkedIn, Twitter
						<br />
						⚡ Fun fact: I play Call of Duty (LVL: 350), building cool tools, learning new things, and
						writing technical contents.
						<br />
						⚡ Looking forward to making some PRs on Open source projects.
					</p>

					<h2 class="mb-4 mt-10 text-xl font-bold dark:text-white">Location</h2>
					<iframe
						title="University of Lagos"
						src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3963.7702705392176!2d3.3730804758700916!3d6.550662722845285!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x103b8d9f1ad0f3b5%3A0x1fadab8a4eca4762!2sThe%20Cocoon%20Luxury%20Suites!5e0!3m2!1sen!2sng!4v1730564630303!5m2!1sen!2sng"
						width="100%"
						height="450"
						style="border:0;"
						allowfullscreen={true}
						loading="lazy"
						referrerpolicy="no-referrer-when-downgrade"
					></iframe>
				</div>
			</div>
		</div>
	</div>
</div>
