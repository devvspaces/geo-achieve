<script>
	import { Avatar, Button, Card, Timeline, GradientButton } from 'flowbite-svelte';
	import { ArrowRightOutline, CalendarWeekSolid } from 'flowbite-svelte-icons';

  
  /**
   * @type {Object<string, string>}
   */
	const certificate = {
		'Issued to': 'John Doe',
		Category: 'Degree',
		Institution: 'University of Lagos',
		Degree: 'BSc Computer Science',
		Location: 'Lagos, Nigeria',
		'Certificate ID': 'HAVARD-CS-24-890',
		'Issued on': 'Monday, 12th April 2021'
	};
</script>

<div>
	<div class="container mx-auto py-8">
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
                  {certificate[key]}</span>
							</div>
						{/each}
					</div>
					<hr class="my-6 border-t border-gray-300 dark:border-gray-700" />
					<div class="flex flex-col">
						<span class="mb-4 text-center font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300"
							>This certificate has been issued by</span
						>
						<div class="mb-8 flex justify-center bg-white p-4 rounded-lg shadow">
							<img
								src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Harvard_University_logo.svg/2560px-Harvard_University_logo.svg.png"
								class="shrink-0 w-full"
								alt="John Doe"
							/>
						</div>
						<div class="flex flex-wrap justify-center gap-4">
							<GradientButton size="md" color="purple" style="width: 100%">
								<span class="text-md font-semibold">View</span>
                <ArrowRightOutline class="w-5 h-5 ms-2" />
							</GradientButton>
						</div>
					</div>
				</div>
			</div>
			<div class="col-span-4 sm:col-span-9">
				<div class="rounded-lg bg-gray-50 p-6 shadow dark:bg-gray-900">
					<img
						src="https://marketplace.canva.com/EAFGv9WhSmc/1/0/1600w/canva-blue-and-yellow-minimalist-employee-of-the-month-certificate-jaIc19nYjY4.jpg"
						class="rounded"
						alt="Certificate"
					/>

					<h2 class="mb-4 mt-6 text-lg font-semibold dark:text-gray-100">HAVARD-CS-24-890</h2>
					<p class="text-sm text-gray-700 dark:text-gray-300">
						Verify at <a
							href="https://verify.com/certificate/HAVARD-CS-24-890"
							class="text-slate-700 underline dark:text-gray-300"
              >https://verify.com/certificate/HAVARD-CS-24-890</a
						>
					</p>
				</div>
			</div>
		</div>
	</div>
</div>
