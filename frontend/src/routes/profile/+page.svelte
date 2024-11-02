<script>
	import {
		Avatar,
		Button,
		Card,
		Timeline,
		TimelineItem,
		Modal,
		Label,
		Input,
		Textarea,
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
	let imageUrl = $state('https://avatars.githubusercontent.com/u/77179231?v=4');

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
</script>

<Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#">
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
				<Input type="text" name="name" placeholder="John Doe" required />
			</Label>
			<Label class="space-y-2">
				<span>Tagline</span>
				<Input type="text" name="password" placeholder="Software Engineer" required />
			</Label>
		</div>
		<div class="space-y-2">
			<Label for="description" class="mb-2">Description</Label>
			<Editor
				apiKey="wi0le1jhy3ib3c25miowo9cq4rw1rt2z4epba95r1lpwqte0"
				channel="7"
				value="<p>Hello, Talk about yourself <strong>here</strong>...</p>"
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
		<Button type="submit" class="w-full1">Update</Button>
	</form>
</Modal>

<div>
	<div class="container mx-auto py-8">
		<div class="grid grid-cols-4 gap-6 px-4 sm:grid-cols-12">
			<div class="col-span-4 sm:col-span-3">
				<div class="sticky top-0 rounded-lg bg-gray-100 p-6 shadow dark:bg-gray-900">
					<div class="flex flex-col items-center">
						<img
							src="https://avatars.githubusercontent.com/u/77179231?v=4"
							class="h-50 w-50 mb-4 shrink-0 rounded-full bg-gray-300 object-cover shadow-lg"
							alt="John Doe"
						/>
						<h1 class="text-xl font-bold text-gray-900 dark:text-white">John Doe</h1>
						<p class="text-gray-700 dark:text-gray-300">Software Developer</p>
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
