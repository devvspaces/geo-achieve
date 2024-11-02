<script>
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
		Input	} from 'flowbite-svelte';
	import {
		PlusOutline,
		UserRemoveOutline
	} from 'flowbite-svelte-icons';

	let items = [
		{ id: 1, principal: 'Toyota', name: 'John Doe' },
		{ id: 2, principal: 'Toyota', name: 'John Doe' },
		{ id: 3, principal: 'Toyota', name: 'John Doe' },
		{ id: 4, principal: 'Toyota', name: 'John Doe' },
		{ id: 5, principal: 'Toyota', name: 'John Doe' },
		{ id: 6, principal: 'Toyota', name: 'John Doe' },
		{ id: 7, principal: 'Toyota', name: 'John Doe' },
		{ id: 8, principal: 'Toyota', name: 'John Doe' },
		{ id: 9, principal: 'Toyota', name: 'John Doe' },
		{ id: 10, principal: 'Toyota', name: 'John Doe' },
		{ id: 11, principal: 'Toyota', name: 'John Doe' },
		{ id: 12, principal: 'Toyota', name: 'John Doe' },
		{ id: 13, principal: 'Toyota', name: 'John Doe' }
	];

	let formModal = $state(false);
</script>

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
				<TableBodyRow class="dark:border-gray-800 border-gray-300" slot="row" let:item>
					<TableBodyCell class="text-gray-900">{item.id}</TableBodyCell>
					<TableBodyCell class="text-gray-900">{item.principal}</TableBodyCell>
					<TableBodyCell class="text-gray-900">{item.name}</TableBodyCell>
					<TableBodyCell class="text-gray-900"></TableBodyCell>
          <TableBodyCell tdClass="">
            <Button size="xs" color="red"
              >Revoke<UserRemoveOutline class="ml-2 h-4 w-4 " /></Button
            >
          </TableBodyCell>
				</TableBodyRow>
			</TableBody>
		</Table>
	</div>
</div>
