<script>
	import { Card, Button, Label, Input, Checkbox, Fileupload } from 'flowbite-svelte';
	import {
		EditOutline,
		LinkedinSolid,
		GithubSolid,
		TwitterSolid,
		YoutubeSolid
	} from 'flowbite-svelte-icons';
	import Editor from '@tinymce/tinymce-svelte';
	import { onMount } from 'svelte';

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

	let imageUrl = $state(
		'https://shop.raceya.fit/wp-content/uploads/2020/11/logo-placeholder.jpg'
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

  onMount(() => {
    updateLocation();
  });

</script>

<div
	style="min-height: calc(100vh - 15rem);"
	class="container mx-auto flex max-w-screen-xl flex-col items-center justify-center px-4 py-8 lg:px-12"
>
	<Card size="lg">
		<form class="flex flex-col space-y-6" action="#">
			<h3 class="mb-2 text-center text-xl font-medium text-gray-900 dark:text-white">
				Create New Institution Account
			</h3>
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
					<Input type="number" name="latitude" bind:value={latitude} required />
				</Label>
				<Label class="space-y-2">
					<span>Longitude</span>
					<Input type="number" name="latitude" bind:value={longitude} required />
				</Label>
				<Button class="ms-auto" on:click={updateLocation} color="alternative">Update</Button>
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
			<Button color="purple" type="submit" class="w-full1">Register</Button>
		</form>
	</Card>
</div>
