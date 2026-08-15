<script lang="ts">
    import { APP } from '@stores/stores.svelte';
    import { Send } from '@enums/events';
    import { SendEvent } from '@utils/eventsHandlers';
    import ScreenHeader from '@components/ScreenHeader.svelte';
    import Icon from '@components/Icon.svelte';
    import NationalityDropdown from '@components/NationalityDropdown.svelte';

    let firstname = $state('');
    let lastname = $state('');
    let nationality = $state(APP.defaultNationality);
    let gender = $state<'male' | 'female'>('female');
    let height = $state(APP.identity.defaultHeight);
    let birthdate = $state('');
    let submitting = $state(false);
    let errors = $state({
        firstname: '',
        lastname: '',
        nationality: '',
        gender: '',
        height: '',
        birthdate: '',
    });

    const heightPct = $derived(
        ((height - APP.identity.minHeight) / (APP.identity.maxHeight - APP.identity.minHeight)) * 100,
    );

    function formatDob(value: string) {
        const digits = value.replace(/\D/g, '').slice(0, 8);
        const mm = digits.slice(0, 2);
        const dd = digits.slice(2, 4);
        const yyyy = digits.slice(4, 8);
        if (digits.length <= 2) return mm;
        if (digits.length <= 4) return `${mm}/${dd}`;
        return `${mm}/${dd}/${yyyy}`;
    }

    function validName(value: string) {
        return /^[A-Z][a-zA-Z]{1,15}$/.test(value);
    }

    function ageFromDob(value: string) {
        const match = value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
        if (!match) return -1;
        const month = Number(match[1]);
        const day = Number(match[2]);
        const year = Number(match[3]);
        if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900) return -1;
        const dob = new Date(year, month - 1, day);
        if (dob.getMonth() !== month - 1 || dob.getDate() !== day) return -1;
        const now = new Date();
        let age = now.getFullYear() - year;
        const hadBirthday =
            now.getMonth() > month - 1 || (now.getMonth() === month - 1 && now.getDate() >= day);
        if (!hadBirthday) age -= 1;
        return age;
    }

    function nameError(value: string) {
        if (!value) return 'Enter a name';
        if (!validName(value)) return 'Must start with a capital letter';
        return '';
    }

    async function confirm() {
        if (submitting) return;

        const next = {
            firstname: nameError(firstname),
            lastname: nameError(lastname),
            nationality: APP.nationalities.some((option) => option.name === nationality) ? '' : 'Select a nationality',
            gender: gender ? '' : 'Select one or the other',
            height: height < APP.identity.minHeight ? `Must be above ${APP.identity.minHeight}cm` : '',
            birthdate: ageFromDob(birthdate) < APP.identity.minAge ? `Must be older than ${APP.identity.minAge}+` : '',
        };

        errors = next;
        if (Object.values(next).some(Boolean)) return;

        submitting = true;
        await SendEvent(Send.createCharacter, {
            character: {
                cid: APP.creatingCid,
                firstname,
                lastname,
                nationality,
                gender,
                birthdate,
                height,
            },
        });
        submitting = false;
    }
</script>

<section class="screen-enter flex h-full w-[30vw] min-w-[380px] max-w-[520px] flex-col py-[6.2vh]">
    <ScreenHeader
        serverName={APP.serverName}
        action="Create Your Character"
        title="New Character"
        subtitle="Registration"
    />

    <div class="flex min-h-0 flex-1 flex-col justify-between py-[1.4vh]">
        <div class="flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <Icon name="User" class="mt-[0.15vh] h-[0.95vw] w-[0.95vw] min-h-[16px] min-w-[16px]" />
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">First Name</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Use capital first letter</p>
                </div>
            </div>
            <input
                class="h-[4.4vh] w-full rounded-md border bg-surface px-[0.9vw] text-[0.78vw] text-white outline-none placeholder:text-white/50 {errors.firstname ? 'border-danger' : 'border-transparent'}"
                placeholder="First Name"
                maxlength="16"
                bind:value={firstname}
                oninput={() => (errors.firstname = '')}
            />
            {#if errors.firstname}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.firstname}</p>
            {/if}
        </div>

        <div class="flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <Icon name="User" class="mt-[0.15vh] h-[0.95vw] w-[0.95vw] min-h-[16px] min-w-[16px]" />
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">Last Name</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Use capital first letter</p>
                </div>
            </div>
            <input
                class="h-[4.4vh] w-full rounded-md border bg-surface px-[0.9vw] text-[0.78vw] text-white outline-none placeholder:text-white/50 {errors.lastname ? 'border-danger' : 'border-transparent'}"
                placeholder="Last Name"
                maxlength="16"
                bind:value={lastname}
                oninput={() => (errors.lastname = '')}
            />
            {#if errors.lastname}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.lastname}</p>
            {/if}
        </div>

        <div class="relative z-20 flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <Icon name="Flag" class="mt-[0.15vh] h-[0.95vw] w-[0.95vw] min-h-[16px] min-w-[16px]" />
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">Nationality</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Select one from the list</p>
                </div>
            </div>
            <NationalityDropdown options={APP.nationalities} bind:value={nationality} invalid={!!errors.nationality} onchange={() => (errors.nationality = '')} />
            {#if errors.nationality}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.nationality}</p>
            {/if}
        </div>

        <div class="flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <div class="mt-[0.15vh] flex min-w-[16px] items-center">
                    <Icon name="GenderMale" class="h-[0.85vw] w-[0.85vw]" />
                    <Icon name="GenderFemale" class="-ml-[0.2vw] h-[0.85vw] w-[0.85vw]" />
                </div>
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">Gender</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Select one or the other</p>
                </div>
            </div>
            <div class="grid grid-cols-2 gap-[0.55vw]">
                <button
                    class="flex h-[4.4vh] cursor-pointer items-center justify-center gap-[0.4vw] rounded-md border-0 text-[0.78vw] font-medium transition-colors duration-200 {gender === 'male' ? 'bg-white/30 text-white' : 'bg-surface text-white/90'}"
                    onclick={() => (gender = 'male')}
                >
                    <Icon name="GenderMale" class="h-[0.85vw] w-[0.85vw]" />
                    Male
                </button>
                <button
                    class="flex h-[4.4vh] cursor-pointer items-center justify-center gap-[0.4vw] rounded-md border-0 text-[0.78vw] font-medium transition-colors duration-200 {gender === 'female' ? 'bg-white/30 text-white' : 'bg-surface text-white/90'}"
                    onclick={() => (gender = 'female')}
                >
                    <Icon name="GenderFemale" class="h-[0.85vw] w-[0.85vw]" />
                    Female
                </button>
            </div>
            {#if errors.gender}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.gender}</p>
            {/if}
        </div>

        <div class="flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <Icon name="Ruler" class="mt-[0.15vh] h-[0.95vw] w-[0.95vw] min-h-[16px] min-w-[16px]" />
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">Height</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Must be above {APP.identity.minHeight}cm</p>
                </div>
            </div>
            <div class="flex items-center gap-[0.7vw]">
                <div class="flex h-[3.3vh] min-w-[2.4vw] items-center justify-center rounded-md border px-[0.45vw] text-[0.78vw] font-medium text-white {errors.height ? 'border-danger bg-surface' : 'border-transparent bg-surface'}">
                    {height}
                </div>
                <input
                    class="slider"
                    type="range"
                    min={APP.identity.minHeight}
                    max={APP.identity.maxHeight}
                    step="1"
                    bind:value={height}
                    style={`--pct: ${heightPct}%`}
                />
            </div>
            {#if errors.height}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.height}</p>
            {/if}
        </div>

        <div class="flex flex-col gap-[0.65vh]">
            <div class="flex items-start gap-[0.55vw]">
                <Icon name="CalendarBlank" class="mt-[0.15vh] h-[0.95vw] w-[0.95vw] min-h-[16px] min-w-[16px]" />
                <div>
                    <p class="m-0 text-[0.84vw] font-semibold leading-[1.15] text-white">Date of Birth</p>
                    <p class="mt-[0.05vh] text-[0.62vw] font-normal leading-[1.2] text-white/70">Must be older than {APP.identity.minAge}+</p>
                </div>
            </div>
            <input
                class="h-[4.4vh] w-full rounded-md border bg-surface px-[0.9vw] text-[0.78vw] text-white outline-none placeholder:text-white/50 {errors.birthdate ? 'border-danger' : 'border-transparent'}"
                placeholder="MM/DD/YYYY"
                maxlength="10"
                value={birthdate}
                oninput={(e) => {
                    birthdate = formatDob((e.currentTarget as HTMLInputElement).value);
                    errors.birthdate = '';
                }}
            />
            {#if errors.birthdate}
                <p class="error-in m-0 text-[0.6vw] font-medium text-danger">{errors.birthdate}</p>
            {/if}
        </div>
    </div>

    <div class="shrink-0 pt-[1.6vh]">
        <button class="h-[4.8vh] w-full cursor-pointer rounded-md border-0 bg-accent text-[0.95vw] font-bold tracking-[-0.01em] text-white disabled:cursor-default disabled:opacity-70" onclick={confirm} disabled={submitting}>
            Confirm
        </button>
        <p class="mt-[1.1vh] text-center text-[0.62vw] font-normal text-white/80">Once you confirm, changes are final</p>
    </div>
</section>
