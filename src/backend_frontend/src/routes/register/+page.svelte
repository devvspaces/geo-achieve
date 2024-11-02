<script>
	import { Card, GradientButton } from 'flowbite-svelte';
	import { ArrowRightOutline } from 'flowbite-svelte-icons';
</script>

<div
	style="min-height: calc(100vh - 15rem);"
	class="container mx-auto flex max-w-screen-xl flex-col justify-center px-4 py-8 lg:px-12"
>
	<div class="text-center">
		<h2 class="mb-10 text-center text-4xl font-bold tracking-tight text-gray-900 dark:text-white">
			What do you want to achieve?
		</h2>

		<div class="flex justify-center gap-8">
			<Card>
				<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
					Get Certificates
				</h5>
				<p class="mb-6 font-normal leading-tight text-gray-700 dark:text-gray-400">
					Do you want to receive certificates from institutions?
				</p>
				<a href="/register/account" class="w-full">
					<GradientButton color="purpleToBlue" class="w-full">
						Next <ArrowRightOutline class="ms-2 h-6 w-6 text-white" />
					</GradientButton></a
				>
			</Card>
			<Card>
				<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
					Issue Certificates
				</h5>
				<p class="mb-6 font-normal leading-tight text-gray-700 dark:text-gray-400">
					Are you an institution that wants to issue certificates?
				</p>
				<a href="/register/institution" class="w-full">
					<GradientButton color="purpleToBlue" class="w-full">
						Next <ArrowRightOutline class="ms-2 h-6 w-6 text-white" />
					</GradientButton>
				</a>
			</Card>
		</div>
	</div>
</div>
