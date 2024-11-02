<script>
	import { onMount } from 'svelte';
	import {
		TableBody,
		TableBodyCell,
		TableBodyRow,
		TableHead,
		TableHeadCell,
		TableSearch,
		Button,
		Dropdown,
		DropdownItem,
		Checkbox,
		ButtonGroup,
		Modal,
		Fileupload,
		Label,
		Input,
		Select
	} from 'flowbite-svelte';
	import { Section } from 'flowbite-svelte-blocks';
	import {
		PlusOutline,
		ChevronDownOutline,
		FilterSolid,
		ChevronRightOutline,
		ChevronLeftOutline,
		EyeOutline,
		UserRemoveOutline
	} from 'flowbite-svelte-icons';

	let divClass = 'bg-white dark:bg-gray-900 relative shadow-md sm:rounded-lg overflow-hidden';
	let innerDivClass =
		'flex flex-col md:flex-row items-center justify-between space-y-3 md:space-y-0 md:space-x-4 p-4';
	let searchClass = 'w-full md:w-1/2 relative';
	let svgDivClass = 'absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none';
	let classInput =
		'text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2  pl-10';

	let searchTerm = '';
	let currentPosition = $state(0);
	const itemsPerPage = $state(10);
	const showPage = 5;
	let totalPages = 0;
	const paginationData = [
		{
			id: 'HAVARD-CS-345',
			name: 'John Doe',
			degree: 'BSc Computer Science',
			institution: 'University of Lagos',
			location: 'Lagos, Nigeria',
			category: 'Degree',
			issued_on: 'Monday, 12th April 2021'
		}
	];

	/**
	 * @type {Number[]}
	 */
	let pagesToShow = [];
	let totalItems = paginationData.length;

	/**
	 * @type {Number}
	 */
	let startPage;
	/**
	 * @type {Number}
	 */
	let endPage;

	const updateDataAndPagination = () => {
		const currentPageItems = paginationData.slice(currentPosition, currentPosition + itemsPerPage);
		renderPagination(currentPageItems.length);
	};

	const loadNextPage = () => {
		if (currentPosition + itemsPerPage < paginationData.length) {
			currentPosition += itemsPerPage;
			updateDataAndPagination();
		}
	};

	const loadPreviousPage = () => {
		if (currentPosition - itemsPerPage >= 0) {
			currentPosition -= itemsPerPage;
			updateDataAndPagination();
		}
	};

	const renderPagination = (/** @type {number} */ totalItems) => {
		totalPages = Math.ceil(paginationData.length / itemsPerPage);
		const currentPage = Math.ceil((currentPosition + 1) / itemsPerPage);

		startPage = currentPage - Math.floor(showPage / 2);
		startPage = Math.max(1, startPage);
		endPage = Math.min(startPage + showPage - 1, totalPages);

		pagesToShow = Array.from({ length: endPage - startPage + 1 }, (_, i) => startPage + i);
	};

	const goToPage = (/** @type {number} */ pageNumber) => {
		currentPosition = (pageNumber - 1) * itemsPerPage;
		updateDataAndPagination();
	};

	let startRange = $derived(currentPosition + 1);
	let endRange = $derived(Math.min(currentPosition + itemsPerPage, totalItems));

	onMount(() => {
		// Call renderPagination when the component initially mounts
		renderPagination(paginationData.length);
	});

	let currentPageItems = $derived(
		paginationData.slice(currentPosition, currentPosition + itemsPerPage)
	);
	let filteredItems = $derived(
		paginationData.filter(
			(item) => item.name.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1
		)
	);

	let imageUrl = $state(
		'https://i.etsystatic.com/23383377/r/il/833db7/3235267495/il_fullxfull.3235267495_cdo5.jpg'
	);
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
	let formModal = $state(false);

	let categories = [
		{ value: 'degree', name: 'Degree' },
		{ value: 'workshop', name: 'Workshops' },
		{ value: 'certification', name: 'Certifications' },
		{ value: 'seminar', name: 'Seminars' }
	];
	let selectedCategory = $state('degree');

	let removeModal = $state(false);
	const handleCancel = () => {
		alert('Clicked cancel');
	};
	const handleDelete = () => {
		alert('Clicked delete');
	};
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
		Are you sure you want to revoke this certificate?
	</p>
	<div class="flex items-center justify-center space-x-4">
		<Button color="light" on:click={handleCancel}>No, cancel</Button>
		<Button color="red" on:click={handleDelete}>Yes, I'm sure</Button>
	</div>
</Modal>

<Modal bind:open={formModal} size="lg" autoclose={false} class="w-full">
	<form class="flex flex-col space-y-6" action="#">
		<h3 class="mb-2 text-xl font-medium text-gray-900 dark:text-white">Issue a new certificate</h3>
		<div class="flex items-start gap-4">
			<img
				src={imageUrl}
				class="mb-4 rounded-md bg-gray-300 object-cover object-cover shadow-lg"
				alt="John Doe"
				style="width: 100%; max-width: 500px; min-height: 300px;"
			/>
			<Fileupload id="profile_image" accept=".png,.jpg,.jpeg" on:change={handleFileChange} />
		</div>

		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<Label class="space-y-2">
				<span>Name</span>
				<Input type="text" name="certname" placeholder="Bachelor of Science" required />
			</Label>
			<div>
				<Label for="category">Select an option</Label>
				<Select id="category" class="mt-2" bind:value={selectedCategory} placeholder="">
					{#each categories as { value, name }}
						<option {value}>{name}</option>
					{/each}
				</Select>
			</div>
		</div>

		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<Label class="space-y-2">
				<span>Recipient Principal</span>
				<Input type="text" name="recipient" required />
			</Label>
			<Label class="space-y-2">
				<span>Recipient Full-name</span>
				<Input type="text" name="name" placeholder="John Doe" required />
			</Label>
		</div>

		<div
			id="degree"
			class="grid grid-cols-1 gap-4 md:grid-cols-2"
			class:hidden={selectedCategory != 'degree'}
		>
			<Label class="space-y-2">
				<span>Majors</span>
				<Input type="text" name="majors" placeholder="Computer science" />
			</Label>
			<Label class="space-y-2">
				<span>GPA</span>
				<Input type="number" name="gpa" placeholder="3.5" />
			</Label>
			<Label class="space-y-2">
				<span>Honours</span>
				<Input type="text" name="name" placeholder="First Class" />
			</Label>
		</div>

		<div
			id="workshop"
			class="grid grid-cols-1 gap-4 md:grid-cols-2"
			class:hidden={selectedCategory == 'degree'}
		>
			<Label class="space-y-2">
				<span>Duration</span>
				<Input type="text" name="duration" placeholder="22 hours" />
			</Label>
			<Label class="space-y-2">
				<span>Skills</span>
				<Input type="text" name="skills" placeholder="Machine Learning, Data analysis ..." />
			</Label>
		</div>

		<Button type="submit" class="w-full1">Create</Button>
	</form>
</Modal>

<div style="min-height: calc(100vh - 15rem);">
	<div class="container mx-auto max-w-screen-xl px-4 py-8 lg:px-12">
		<h1 class="text-2xl font-semibold text-gray-900 dark:text-white">Certificates</h1>
	</div>

	<Section name="advancedTable" classSection="">
		<TableSearch
			placeholder="Search"
			hoverable={true}
			bind:inputValue={searchTerm}
			{divClass}
			{innerDivClass}
			{searchClass}
			{classInput}
		>
			<div
				slot="header"
				class="flex w-full flex-shrink-0 flex-col items-stretch justify-end space-y-2 md:w-auto md:flex-row md:items-center md:space-x-3 md:space-y-0"
			>
				<Button color="purple" on:click={() => (formModal = true)}>
					<PlusOutline class="mr-2 h-3.5 w-3.5" />Issue Certificate
				</Button>
				<Button color="alternative">Filter<FilterSolid class="ml-2 h-3 w-3 " /></Button>
				<Dropdown class="w-48 space-y-2 p-3 text-sm">
					<h6 class="mb-3 text-sm font-medium text-gray-900 dark:text-white">Choose category</h6>
					<li>
						<Checkbox>Degree (56)</Checkbox>
					</li>
					<li>
						<Checkbox>Workshop (16)</Checkbox>
					</li>
				</Dropdown>
			</div>
			<TableHead>
				<TableHeadCell padding="px-4 py-3" scope="col">ID</TableHeadCell>
				<TableHeadCell padding="px-4 py-3" scope="col">Category</TableHeadCell>
				<TableHeadCell padding="px-4 py-3" scope="col">Issued To</TableHeadCell>
				<TableHeadCell padding="px-4 py-3" scope="col">Issued On</TableHeadCell>
				<TableHeadCell padding="px-4 py-3" scope="col">Actions</TableHeadCell>
			</TableHead>
			<TableBody class="divide-y">
				{#if searchTerm !== ''}
					{#each filteredItems as item (item.id)}
						<TableBodyRow>
							<TableBodyCell tdClass="px-4 py-3">{item.id}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.category}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.name}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.issued_on}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">
								<a href={`/certificate/${item.id}`}>
									<Button size="sm" color="purple">View<EyeOutline class="ml-2 h-4 w-4" /></Button>
								</a>
								<Button on:click={() => (removeModal = true)} size="sm" color="red"
									>Revoke<UserRemoveOutline class="ml-2 h-4 w-4 " /></Button
								>
							</TableBodyCell>
						</TableBodyRow>
					{/each}
				{:else}
					{#each currentPageItems as item (item.id)}
						<TableBodyRow>
							<TableBodyCell tdClass="px-4 py-3">{item.id}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.category}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.name}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">{item.issued_on}</TableBodyCell>
							<TableBodyCell tdClass="px-4 py-3">
								<a href={`/certificate/${item.id}`}>
									<Button size="sm" color="purple">View<EyeOutline class="ml-2 h-4 w-4" /></Button>
								</a>
								<Button on:click={() => (removeModal = true)} size="sm" color="red"
									>Revoke<UserRemoveOutline class="ml-2 h-4 w-4 " /></Button
								>
							</TableBodyCell>
						</TableBodyRow>
					{/each}
				{/if}
			</TableBody>
			<div
				slot="footer"
				class="flex flex-col items-start justify-between space-y-3 p-4 md:flex-row md:items-center md:space-y-0"
				aria-label="Table navigation"
			>
				<span class="text-sm font-normal text-gray-500 dark:text-gray-400">
					Showing
					<span class="font-semibold text-gray-900 dark:text-white">{startRange}-{endRange}</span>
					of
					<span class="font-semibold text-gray-900 dark:text-white">{totalItems}</span>
				</span>
				<ButtonGroup>
					<Button on:click={loadPreviousPage} disabled={currentPosition === 0}
						><ChevronLeftOutline size="xs" class="m-1.5" /></Button
					>
					{#each pagesToShow as pageNumber}
						<Button on:click={() => goToPage(pageNumber)}>{pageNumber}</Button>
					{/each}
					<Button on:click={loadNextPage} disabled={totalPages === endPage}
						><ChevronRightOutline size="xs" class="m-1.5" /></Button
					>
				</ButtonGroup>
			</div>
		</TableSearch>
	</Section>
</div>
