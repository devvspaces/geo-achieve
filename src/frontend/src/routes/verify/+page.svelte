<script>
	import { Search, Button, Dropdown, DropdownItem } from 'flowbite-svelte';
	import { ChevronDownOutline } from 'flowbite-svelte-icons';

	const items = [
		{
			label: 'Certificate'
		},
		{
			label: 'Institution'
		}
	];

	let selectCategory = $state('Certificate');
</script>

<div
	class="container mx-auto flex max-w-2xl items-center justify-center py-8"
	style="min-height: calc(100vh - 15rem);"
>
	<div class="w-full">
		<h2 class="mb-4 text-center text-2xl font-semibold dark:text-white">Verify {selectCategory}</h2>
		<form class="flex">
			<div class="relative">
				<Button class="border-primary-700 whitespace-nowrap rounded-e-none border border-e-0">
					{selectCategory}
					<ChevronDownOutline class="ms-2.5 h-2.5 w-2.5" />
				</Button>
				<Dropdown classContainer="w-40">
					{#each items as { label }}
						<DropdownItem
							on:click={() => {
								selectCategory = label;
							}}
							class={selectCategory === label ? 'underline' : ''}
						>
							{label}
						</DropdownItem>
					{/each}
				</Dropdown>
			</div>
			<Search
				size="md"
				class="py-2.5"
				style="border-radius: 0 0.5rem 0.5rem 0;"
				placeholder={`Search / Verify ${selectCategory} ID`}
			>
				<Button>Search</Button>
			</Search>
		</form>
	</div>
</div>
