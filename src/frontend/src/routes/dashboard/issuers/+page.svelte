<script>
	import { store } from '$lib/store';
	import {
		Table,
		TableBody,
		TableBodyCell,
		TableBodyRow,
		TableHead,
		TableHeadCell,
		Button,
		Modal,
		Label,
		Input
	} from 'flowbite-svelte';
	import { PlusOutline, UserRemoveOutline } from 'flowbite-svelte-icons';

	/**
	 * @type {never[]}
	 */
	let items = $state([]);

	let formModal = $state(false);
	let removeModal = $state(false);
	const handleCancel = () => {
		alert('Clicked cancel');
	};
	const handleDelete = () => {
		alert('Clicked delete');
	};

	/**
 * @type ({
  backendActor: typeof import("../../../../../declarations/backend").backend | null,
  principal: import("@dfinity/principal").Principal | null;
  error: string;
  isLoading: boolean;
})
 */
	let storeState = $state({
		backendActor: null,
		principal: null,
		error: '',
		isLoading: false,
	});
	store.subscribe((value) => {
		storeState = value;
	});

  $effect(() => {
    // const response = storeState.backendActor?.get_issuers();
  })
</script>

<Modal title="" bind:open={removeModal} autoclose size="sm" class="w-full">
	<svg
		class="mx-auto mb-3.5 h-11 w-11 text-gray-400 dark:text-gray-500"
		aria-hidden="true"
		fill="currentColor"
		viewBox="0 0 20 20"
		xmlns="http://www.w3.org/2000/svg"
		><path
			fill-rule="evenodd"
			d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
			clip-rule="evenodd"
		/></svg
	>
	<p class="mb-4 text-center text-gray-500 dark:text-gray-300">
		Are you sure you want to remove this issuer?
	</p>
	<div class="flex items-center justify-center space-x-4">
		<Button color="light" on:click={handleCancel}>No, cancel</Button>
		<Button color="red" on:click={handleDelete}>Yes, I'm sure</Button>
	</div>
</Modal>

<Modal bind:open={formModal} size="sm" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#">
		<h3 class="mb-2 text-xl font-medium text-gray-900 dark:text-white">Create a new issuer</h3>
		<Label class="space-y-2">
			<span>Issuer Principal</span>
			<Input type="text" name="recipient" required />
		</Label>
		<Label class="space-y-2">
			<span>Issuer Full-name</span>
			<Input type="text" name="name" placeholder="John Doe" required />
		</Label>
		<Button type="submit" class="w-full1">Create</Button>
	</form>
</Modal>

<div style="min-height: calc(100vh - 15rem);">
	<div class="container mx-auto max-w-screen-xl px-4 py-8 lg:px-12">
		<div
			class="mb-6 flex w-full flex-shrink-0 flex-col items-stretch justify-between space-y-2 md:w-auto md:flex-row md:items-center md:space-x-3 md:space-y-0"
		>
			<h1 class="text-2xl font-semibold text-gray-900 dark:text-white">Manage Issuers List</h1>
			<Button on:click={() => (formModal = true)}>
				<PlusOutline class="mr-2 h-3.5 w-3.5" />Create Issuer
			</Button>
		</div>
		<Table
			color="custom"
			shadow
			{items}
			placeholder="Search by issuer name"
			filter={(item, searchTerm) => item.name.toLowerCase().includes(searchTerm.toLowerCase())}
			divClass="dark:bg-gray-900 dark:text-white bg-gray-100 text-gray-900"
		>
			<TableHead>
				<TableHeadCell>ID</TableHeadCell>
				<TableHeadCell>Principal</TableHeadCell>
				<TableHeadCell>Name</TableHeadCell>
			</TableHead>
			<TableBody tableBodyClass="divide-y">
				<TableBodyRow class="border-gray-300 dark:border-gray-800" slot="row" let:item>
					<TableBodyCell class="text-gray-900">{item.id}</TableBodyCell>
					<TableBodyCell class="text-gray-900">{item.principal}</TableBodyCell>
					<TableBodyCell class="text-gray-900">{item.name}</TableBodyCell>
					<TableBodyCell class="text-gray-900"></TableBodyCell>
					<TableBodyCell tdClass="">
						<Button on:click={() => (removeModal = true)} size="xs" color="red"
							>Revoke<UserRemoveOutline class="ml-2 h-4 w-4 " /></Button
						>
					</TableBodyCell>
				</TableBodyRow>
			</TableBody>
		</Table>
	</div>
</div>
